{ lib, config, ... }:
let
  cfg = config.blume.theme;
in
{

  options.blume.theme = {
    enable = lib.mkEnableOption "Blume Corporation theme";

    brand = lib.mkOption {
      type = lib.types.str;
      default = "Blume Corporation";
      description = "Brand text used by themed login surfaces.";
    };

    palette = lib.mkOption {
      type = lib.types.enum [
        "amber-black"
        "cyan-dark"
        "mono-accent"
      ];
      default = "amber-black";
      description = "Theme palette identifier.";
    };

    loginSurfaces = {
      sshBanner.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable pre-auth SSH banner.";
      };

      shellMotd.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable shell MOTD metadata export.";
      };
    };

    motd.mode = lib.mkOption {
      type = lib.types.enum [
        "system-status"
        "lore"
        "security"
      ];
      default = "system-status";
      description = "MOTD content mode.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.loginSurfaces.sshBanner.enable {
        environment.etc."issue.net".text = ''
          [ctOS] ${cfg.brand}
          Access is monitored and logged.
          Unauthorized activity is prohibited.
        '';
        services.openssh.settings.Banner = "/etc/issue.net";
      })

      (lib.mkIf cfg.loginSurfaces.shellMotd.enable {
        environment.variables.BLUME_THEME_BRAND = cfg.brand;
        environment.variables.BLUME_THEME_PALETTE = cfg.palette;
        environment.variables.BLUME_THEME_MOTD_MODE = cfg.motd.mode;

        environment.etc."blume/motd_ascii".text = ''

           _____  _      _    _  __  __ ______ 
          |  __ \| |    | |  | ||  \/  |  ____|
          | |__) | |    | |  | || \  / | |__   
          |  __ <| |    | |  | || |\/| |  __|  
          | |__) | |____| |__| || |  | | |____ 
          |_____/|______|\____/ |_|  |_|______|
                                               
           C E N T R A L  O P E R A T I N G  S Y S T E M
        '';
      })
    ]
  );
}
