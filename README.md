<h1 align="left">Seyhan's NixOS Configuration</h1>

<ul align="left">
  <li><a href="#preface">Preface</a></li>
  <li><a href="#screenshots">Screenshots</a></li>
  <li><a href="#devices">Devices</a></li>
  <li><a href="#repository-structure">Structure</a></li>
  <li><a href="#design-considerations">Design</a></li>
</ul>

## Preface

[nix]: https://nix.dev/manual/nix/stable/
[nixos]: https://nixos.org/manual/nixos/stable/
[nixpkgs]: https://nixos.org/manual/nixpkgs/stable/
[home-manager]: https://nix-community.github.io/home-manager/

This is the configuration for `arda-nirvana`, the laptop I use nowadays. For now, I'm developing my NixOS configuration on
this device, and eventually, I plan to turn it into a home server by building a custom chassis and add-ons for it.
Home Manager runs as a NixOS module here, so the system and my user environment are built from a single evaluation and
share one nixpkgs instance. Everything in this tree is parameterised for the machine that exists now.

I wrote it to be read. Every setting that is not obvious carries the reason it is there in a comment beside it. A wiki page about a config drifts away from the config within months, and a comment moves with the line it explains.

<!-- deno-fmt-ignore-start -->

> [!CAUTION]
> This is one device's configuration at the moment, and not a framework. It hardcodes a hostname, a username,
> a wireless interface, two disk labels and a timezone, and it assumes an Intel laptop with no discrete GPU.
> Do not point an installer at it and expect a bootable system. You can still try your luck, though.
>
> Installation is left to the manuals on purpose. The [Nix][nix], [NixOS][nixos],
> [Nixpkgs][nixpkgs] and [Home Manager][home-manager] manuals already do that job, and they are
> kept current by people who are not me. What this file carries instead is the reasoning.

<!-- deno-fmt-ignore-end -->

## Screenshots

<img width="1920" height="1080" src="https://github.com/user-attachments/assets/881d0420-88a9-4fb1-a347-ac2c82be15de" />
<img width="1920" height="1080" src="https://github.com/user-attachments/assets/fd46ece0-e78c-4297-affc-e0e3dfe8da2a" />
<img width="1920" height="1080" src="https://github.com/user-attachments/assets/e3ddaa14-5b77-4521-b5e6-6853580f7a66" />

## Devices

| Host           | Platform     | Type   | CPU                                       | Root                           | ESP                      | Interfaces                           |
| -------------- | ------------ | ------ | ----------------------------------------- | ------------------------------ | ------------------------ | ------------------------------------ |
| `arda-nirvana` | x86_64-linux | laptop | 11th Gen Intel Core i7-1165G7, Tiger Lake | NVMe, ext4, labelled `NIXROOT` | vfat, labelled `NIXBOOT` | `wlp0s20f3` wireless, `enp6s0` wired |

No other device yet...

## Repository structure

- [`flake.nix`](flake.nix) names two inputs and delegates. The whole of its output is
  `outputs = inputs: import ./parts {inherit inputs;};`, so the assembly sits somewhere other
  than the file everyone opens first.
- [`parts/`](parts) holds one file per output family, indexed by `parts/default.nix`, where each
  line carries its own trailing note about what it is for. The system is named once as a string
  rather than mapped over a one-element list, because an abstraction over one element is an
  abstraction with nothing to generalise.
- [`hosts/default.nix`](hosts/default.nix) is the device registry and the only file allowed to
  reach into `modules/`. That single restriction is what keeps every file under
  `hosts/arda-nirvana/` free of `../..` paths. `modules/options/device.nix` is first in the
  module list, because both trees branch on what it declares.
- [`modules/`](modules) splits four ways, and the split is meaningful. `core` and `desktop` are
  imported whole through a `default.nix` that contains imports and nothing else. `hardware` and
  `services` have no aggregator, so a host takes only the silicon it physically has and only the
  daemons it opted into. The index is in [`modules/README.md`](modules/README.md).
- [`hosts/arda-nirvana/`](hosts/arda-nirvana) carries host configurations only: the hardware scan, the
  filesystems, the timezone, the device declaration and the TLP profile.
- [`homes/`](homes) maps a user name onto a directory, so adding a user is a name and a directory
  and never a new wiring block. [`homes/seyhan/`](homes/seyhan) splits into `desktop`, `programs`
  and `themes`, indexed in [`homes/seyhan/README.md`](homes/seyhan/README.md).

## Design considerations

These are the rules the tree is held to, and they are the reason it looks the way it does:

- `with lib;` and `with builtins;` do not appear. Names are inherited at the top of a `let`
  block, from the narrowest namespace that provides them, so a reader can tell where any
  identifier came from without evaluating the file in their head.
- The categorised namespaces are preferred over flat `lib`: `lib.modules`, `lib.options`,
  `lib.types`, `lib.lists`.
- A file never imports upwards and never more than one level down. Reaching past a directory
  means its own entry file has stopped being the truth about what it contains.
- Custom options are namespaced under `modules.<area>.<name>`, and the top level of the NixOS
  option tree is left alone.
- A hardware fact (`has*`) is never the same option as a behaviour switch (`enable`), because
  owning the radio is not a reason to leave it listening.
- Two settings that cannot both hold are guarded by an assertion that names the conflict and the
  way out, rather than by a comment asking the reader not to.
- Evaluation is pure. An expression that needs `--impure` is wrong.

## License

[GPL-3.0](LICENSE)
