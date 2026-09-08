# modules

```nix
./core     # defaults every machine gets, imported as a directory
./desktop  # niri session and everything that needs a display attached
./hardware # each chip gets its own file, so the system only takes what is installed
./services # daemons and network plumbing, opted into per host
```
import all of `core` and `desktop` at once through their `default.nix` files. however, i list `hardware` and `services` file by file in `hosts/default.nix` because they don't have a main file to group them
