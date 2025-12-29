{ pkgs, lib, ... }:
# universal audio configuration for all of my unique devices I use day to day
{
  environment = {
    defaultPackages = [ ];

    # fixes alsa configuration issue for my Solo Scarlett 4
    # possibly fixed in the latest version but I have been gassed too many times
    variables = {
      # ALSA_CONFIG_UCM2 = "${
      #   pkgs.stable.alsa-ucm-conf.overrideAttrs (old: {
      #     src = (import ../../npins).alsa-ucm-conf;
      #   })
      # }/share/alsa/ucm2";
    };

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    localBinInPath = true;
  };

  services = {
    pulseaudio.enable = lib.mkForce false;
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };

      wireplumber.extraConfig."zz-device-profiles" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "device.name" = "alsa_card.pci-0000_01_00.1"; } ];
            actions = {
              update-props = {
                "device.profile" = "off";
              };
            };
          }
          {
            matches = [
              {
                "device.name" = "alsa_card.usb-Focusrite_Scarlett_Solo_4th_Gen_S12A7663300686-00";
              }
            ];
            actions = {
              update-props = {
                "device.profile" = "pro-audio";
              };
            };
          }
          {
            matches = [ { "device.name" = "alsa_card.usb-Topping_DX3_Pro_-00"; } ];
            actions = {
              update-props = {
                "device.profile" = "pro-audio";
              };
            };
          }
        ];
      };
    };
  };
}
