{ inputs, config }:
let
  inherit (inputs) nixpkgs self;
  jpdsCaddy = (
    nixpkgs.callPackage
      "${nixpkgs.fetchurl {
        url = "https://raw.githubusercontent.com/jpds/nixpkgs/a33b02fa9d664f31dadc8a874eb1a5dbaa9f4ecf/pkgs/servers/caddy/default.nix";
        hash = "sha256-rmzG/Wbt0T5lF7aElgu/pPcRs5au2sK8FJ+yCj02L/Q=";
      }}"
      {
        externalPlugins = [
          {
            name = "caddy-dns/cloudflare";
            repo = "github.com/caddy-dns/cloudflare";
            version = "e52afcd970f5655d702396bea5b3f99a7500f1a8";
          }
        ];
        vendorHash = "sha256-bjFTHAMJnUoY0TEZSvj4QrH9aDl5IbJrA2FAsS7MBJ8="; # Add this, as explained in https://github.com/NixOS/nixpkgs/pull/259275#issuecomment-1763478985
      }
  );
in
{

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets.caddy_cloudflare_dns_api_token = {
      owner = "caddy";
    };
  };

  services.caddy = {
    enable = true;
    package = jpdsCaddy.overrideAttrs (
      finalAttrs: previousAttrs: rec {
        version = "2.7.6";
        dist = nixpkgs.fetchFromGitHub {
          owner = "caddyserver";
          repo = "dist";
          rev = "v${version}";
          hash = "sha256-uY6MU8iXfGK6+HP2Lc+3iPE5wY35NbGp8pMZWpNVPSg=";
        };
        src = nixpkgs.fetchFromGitHub {
          owner = "caddyserver";
          repo = "caddy";
          rev = "v${version}";
          hash = "sha256-th0R3Q1nGT0q5PGOygtD1/CpJmrT5TYagrwQR4t/Fvg=";
        };
      }
    );

    email = "jack.connors@protonmail.com";
    acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
    globalConfig = '''';
    extraConfig = ''
      (cf_acme_settings) {
        tls {
          import ${config.sops.secrets.caddy_cloudflare_dns_api_token.path}
          resolvers 1.1.1.1 1.0.0.1
          propagation_timeout 2h
        }
      }
    '';
    virtualHosts = {
      "squidjelly.gigglesquid.tech" = {
        extraConfig = ''
          import cf_acme_settings
          reverse_proxy squidjelly.lan.gigglesquid.tech:8096 {
            header_up Host {upstream_hostport}
            # transport http {
            #   tls_insecure_skip_verify
            # }
          }
        '';
      };
      "squidcasts.gigglesquid.tech" = {
        extraConfig = ''
          import cf_acme_settings
          reverse_proxy squidcasts.lan.gigglesquid.tech:13378 {
            header_up Host {upstream_hostport}
          }
        '';
      };
    };
  };
}
