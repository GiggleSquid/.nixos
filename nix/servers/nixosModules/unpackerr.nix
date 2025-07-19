{
  config,
  pkgs,
  lib,
  utils,
  ...
}:
let
  cfg = config.services.unpackerr;

  mkServarrSettingsOptions =
    name:
    lib.mkOption {
      type = lib.types.submodule {
        freeformType = (pkgs.formats.ini { }).type;
        options = {
        };
      };
      example = lib.options.literalExpression ''
        {
        }
      '';
      default = { };
      description = ''
        Attribute set of arbitrary config options.
        Please consult the [documentation](https://unpackerr.zip/docs/install/configuration).

        WARNING: this configuration is stored in the world-readable Nix store!
        For secrets use [](#opt-services.${name}.environmentFiles).
      '';
    };

  mkServarrEnvironmentFiles =
    name:
    lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        Environment file to pass secret configuration values.
        Each line must follow the `${lib.toUpper name}_SECTION_KEY=value` pattern.
        Please consult the [documentation](https://unpackerr.zip/docs/install/configuration).
      '';
    };

  mkServarrSettingsEnvVars =
    name: settings:
    lib.pipe settings [
      (lib.mapAttrsRecursive (
        path: value:
        lib.optionalAttrs (value != null) {
          name = lib.toUpper "${name}_${lib.concatStringsSep "_" path}";
          value = toString (if lib.isBool value then lib.boolToString value else value);
        }
      ))
      (lib.collect (x: lib.isString x.name or false && lib.isString x.value or false))
      lib.listToAttrs
    ];
in
{
  options = {
    services.unpackerr = {
      enable = lib.mkEnableOption "Unpackarr, an archive extraction daemon";

      settings = mkServarrSettingsOptions "unpackerr";

      environmentFiles = mkServarrEnvironmentFiles "unpackerr";

      user = lib.mkOption {
        type = lib.types.str;
        default = "unpackerr";
        description = "User account under which Unpackerr runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "unpackerr";
        description = "Group under which Unpackerr runs.";
      };

      package = lib.mkPackageOption pkgs "unpackerr" { };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.unpackerr = {
      description = "Unpackerr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = mkServarrSettingsEnvVars "UNPACKERR" cfg.settings;
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = utils.escapeSystemdExecArgs [
          (lib.getExe cfg.package)
          "--prefix=UNPACKERR"
        ];
        Restart = "on-failure";
      };
    };

    users.users = lib.mkIf (cfg.user == "unpackerr") {
      unpackerr = {
        group = cfg.group;
        isSystemUser = true;
      };
    };
    users.groups = lib.mkIf (cfg.group == "unpackerr") {
      unpackerr = { };
    };
  };
}
