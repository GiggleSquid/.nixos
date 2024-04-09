{ inputs, config }:
let
  inherit (inputs) self nixpkgs;
in
{
  # sops = {
  #   secrets = {
  #     cloudflare_dns_api_token = { };
  #     lego_pfx_pass = { };
  #   };
  #   defaultSopsFile = "${self}/sops/squid-rig.yaml";
  # };

  # security.acme = {
  #   acceptTerms = true;
  #   defaults = {
  #     server = "https://acme-staging-v02.api.letsencrypt.org/directory";
  #     email = "jack.connors@protonmail.com";
  #     extraLegoFlags = [
  #       "--pfx"
  #       # "--pfx.pass $(cat ${config.sops.secrets.lego_pfx_pass.path})"
  #     ];
  #     dnsResolver = "1.1.1.1";
  #     dnsProvider = "cloudflare";
  #     credentialFiles = {
  #       "CF_DNS_API_TOKEN_FILE" = "${config.sops.secrets.cloudflare_dns_api_token.path}";
  #       "CLOUDFLARE_PROPAGATION_TIMEOUT_FILE" = "${nixpkgs.writeText "CLOUDFLARE_PROPAGATION_TIMEOUT" ''7200''}";
  #     };
  #   };
  #   certs."ns1.dns.lan.gigglesquid.tech" = { };
  # };
}
