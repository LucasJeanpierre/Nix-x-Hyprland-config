{ config, pkgs, ... }:

{
  home.username = "zeta";
  home.homeDirectory = "/home/zeta";
  home.stateVersion = "25.05";
  programs.git.enable = true;
  programs.bash = {
    enable = true;
    shellAliases = {
      zeta = "echo NixOS x Hyrpland Zeta configuration";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "0xff5e81ac";
      };

      bind = [
        "SUPER, Return, exec, kitty"
        "SUPER, Q, killactive"
        "SUPER, M, exit"
      ];
    };
  };
}
