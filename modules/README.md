# modules

```nix
./core     # defaults every machine gets, imported as a directory
./desktop  # the niri session and everything that needs a display attached
./hardware # one file per piece of silicon, so a host takes only what it has
./services # daemons and network plumbing, opted into per host
```

`core` and `desktop` are imported whole through their `default.nix`. `hardware` and `services`
are named file by file in `hosts/default.nix`, since neither carries an aggregator to import
wholesale.
