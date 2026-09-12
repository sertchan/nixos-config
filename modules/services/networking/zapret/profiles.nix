{
  config,
  lib,
  ...
}: let
  inherit (builtins) listToAttrs;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf;

  cfg = config.services.zapret2;
  settings = import ./settings.nix {inherit config lib;};

  fakeTtlFallback = toString 3;
  fakeAutoTtlIpv4 = "-1,3-20";
  fakeAutoTtlIpv6 = "-1,3-20";
  fakeTtlOptions = {
    ipv4 = "ip_ttl=${fakeTtlFallback}:ip_autottl=${fakeAutoTtlIpv4}";
    ipv6 = "ip6_ttl=${fakeTtlFallback}:ip6_autottl=${fakeAutoTtlIpv6}";
  };

  mkProfiles = protocol: autodetect: parameters:
    listToAttrs (map (family: let
      name = "${protocol}-${family}";
    in {
      inherit name;
      value =
        {
          parameters =
            ["--filter-l3=${family}"]
            ++ parameters fakeTtlOptions.${family};
        }
        // optionalAttrs autodetect {
          hosts.autodetect = {
            enable = true;
            file = "${settings.autoHostlistDir}/${name}.txt";
          };
        };
    }) ["ipv4" "ipv6"]);
in
  mkIf cfg.enable {
    services.zapret2.profiles =
      (mkProfiles "http" true (ttlOptions: [
        "--filter-tcp=80"
        "--payload=http_req"
        "--lua-desync=fake:blob=fake_default_http:tcp_md5:fwmark=${settings.splitCompletedMark}:${ttlOptions}"
      ]))
      // (mkProfiles "https" true (ttlOptions: [
        "--filter-tcp=443"
        "--payload=tls_client_hello"
        "--lua-desync=connection_fake:tcp_md5:fwmark=${settings.splitCompletedMark}:${ttlOptions}"
      ]));
  }
