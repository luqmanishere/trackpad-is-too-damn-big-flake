{
  config,
  lib,
  ...
}:
with lib; let
  percentOpt = {
    s,
    p ? 10,
  }:
    mkOption {
      description = "Percentage to ignore/control on the ${s} side";
      type = types.int;
      default = p;
    };
  cfg = config.services.titdb;
in {
  options.services.titdb = {
    enable = mkEnableOption "Whether to enable trackpad-is-too-damn-big as a service";
    package = mkOption {description = "Package for trackpad-is-too-damn-big";};
    device = mkOption {
      description = "Path to the trackpad device";
      type = types.str;
      default = "/dev/input/event0";
    };
    runMode = mkOption {
      description = "Running mode options: p/s/f";
      type = types.enum ["p" "s" "f"];
      default = "f";
    };
    leftPercentage = percentOpt {
      s = "left";
    };
    rightPercentage = percentOpt {
      s = "right";
    };
    topPercentage = percentOpt {
      s = "top";
      p = 0;
    };
    bottomPercentage = percentOpt {
      s = "bottom";
      p = 15;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.titdb = {
      enable = true;
      wantedBy = ["graphical.target"];
      serviceConfig = {
        ExecStart = "+${cfg.package}/bin/titdb -d ${cfg.device} -m ${cfg.runMode} -l ${toString cfg.leftPercentage} -r ${toString cfg.rightPercentage} -t ${toString cfg.topPercentage} -b ${toString cfg.bottomPercentage}";
        RestartSec = 5;
      };
    };
  };
}
