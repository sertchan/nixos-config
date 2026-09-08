<h1 align="left">Seyhan's NixOS Configuration</h1>

<ul align="left">
  <li><a href="#introduction">Introduction</a></li>
  <li><a href="#screenshots">Screenshots</a></li>
  <li><a href="#devices">Devices</a></li>
  <li><a href="#repository-structure">Repository structure</a></li>
  <li><a href="#code-principles">Code principles</a></li>
</ul>

## Introduction

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

- [`flake.nix`](flake.nix) is kept short for a reason. It names two inputs and then hands the rest over:
  `outputs = inputs: import ./parts {inherit inputs;};`. The file you open first is not the file
  that does the work
- [`parts/`](parts) keeps one file per output. `parts/default.nix` lists them, and each line should
  end with an explanation what that file is for. The system is named once, as a plain string. There is no point in mapping over a single-item list: wrapping one thing in a loop generalizes nothing
  and absolutely pointless
- [`hosts/default.nix`](hosts/default.nix) is device registry, and the only file allowed to
  reach into `modules/`. That rule explains why no file under `hosts/arda-nirvana/` ever needs a
  `../..` path. `modules/options/device.nix` comes first in the module list, since both trees decide
  what to do based on what it declares 
- [`modules/`](modules) splits four ways, and the split does real work. `core` and `desktop` come in
  as a whole, through a `default.nix` that holds imports (and nothing else). `hardware` and `services`
  have no `default.nix` file, so a host picks up only part it really has and only the daemons it asked
  for. It has own index. see: [`modules/README.md`](modules/README.md)
- [`hosts/arda-nirvana/`](hosts/arda-nirvana) holds host settings only: initial hardware scan (Which nixos generates during installation process. You know what I'm saying),
  filesystems, timezone, device declaration, TLP profile etc. 
- [`homes/`](homes) maps a user name onto a directory. Adding a user is a name and a directory,
  nothing more; there is no new wiring block to write. [`homes/seyhan/`](homes/seyhan) splits into
  `desktop`, `programs` and `themes`, listed in [`homes/seyhan/README.md`](homes/seyhan/README.md).

## Code principles

I'm writing this down for people who want to contribute to this configuration, or for those who fork it for their own use. I use these Nix principles, and I strongly recommend following them
- Avoid using `with lib;` or `with builtins;`. Instead, bring in the names you need at the top of a `let` block, and take them from the smallest namespace that has them. That way a future reader can see where each name comes from
- Use the grouped namespaces instead of plain `lib`: `lib.modules`, `lib.options`, `lib.types`, `lib.lists`
- A file can import from its own directory or one level below it. It should never import from a directory above. If you need to reach deeper into another directory, that directory's entry file is no longer doing its job
- Put custom options under `modules.<area>.<name>`. Please don't add anything to the top level of the NixOS option tree
- Keep hardware options (`has*`) separate from behaviour options (`enable`). Some devices can have a radio without turning it on
- If two settings cannot be used together, add an assertion that says what the conflict is and how to fix it
- Keep evaluation pure. If an expression needs `--impure`, something is wrong in that code

## License

[GPL-3.0](LICENSE)
