{ lib, ... }:
{
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
