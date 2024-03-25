{ inputs }:
let
  inherit (inputs) nixpkgs;
in
{
  xdg = {
    configFile = {
      "k9s/skins/catppuccin-mocha.yaml" = {
        source = "${
          nixpkgs.catppuccin.override {
            themeList = [ "k9s" ];
            variant = "mocha";
            accent = "peach";
          }
        }/k9s/catppuccin-mocha.yaml";
      };
    };
  };
  programs.k9s = {
    enable = true;
    aliases = {
      aliases = {
        dp = "deployments";
        sec = "v1/secrets";
        jo = "jobs";
        cr = "clusterroles";
        crb = "clusterrolebindings";
        ro = "roles";
        rb = "rolebindings";
        np = "networkpolicies";
      };
    };
    settings = {
      k9s = {
        liveViewAutoRefresh = false;
        screenDumpDir = /home/squid/.local/state/k9s/screen-dumps;
        refreshRate = 2;
        maxConnRetry = 5;
        readOnly = false;
        noExitOnCtrlC = false;
        ui = {
          enableMouse = false;
          headless = false;
          logoless = false;
          crumbsless = false;
          reactive = false;
          noIcons = false;
          defaultsToFullScreen = false;
          skin = "catppuccin-mocha";
        };
        skipLatestRevCheck = false;
        disablePodCounting = false;
        shellPod = {
          image = "busybox:1.35.0";
          namespace = "default";
          limits = {
            cpu = "100m";
            memory = "100Mi";
          };
        };
        imageScans = {
          enable = false;
          exclusions = {
            namespaces = [ ];
            labels = { };
          };
        };
        logger = {
          tail = 100;
          buffer = 5000;
          sinceSeconds = -1;
          textWrap = false;
          showTime = false;
        };
        thresholds = {
          cpu = {
            critical = 90;
            warn = 70;
          };
          memory = {
            critical = 90;
            warn = 70;
          };
        };
      };
    };
  };
}
