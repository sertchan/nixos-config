{ lib, ... }: {
  # I use HaGeZi's Wurzn DNS for blocking Analytics, Metrics, Telemetry, Phishing, Malware, Scam, Fake, Cryptojacking and other harmful domains
  # https://github.com/hagezi/dns-servers

  networking.nameservers = lib.mkForce [
    "159.69.155.94#wurzn.hagezi.org"
    "2a01:4f8:1c1c:d363::1#wurzn.hagezi.org"
  ];
}
