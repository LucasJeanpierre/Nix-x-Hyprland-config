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
      monitor = ",preferred,auto,1";
      exec-once = [
        "waybar"
        "mako"
        "nm-applet --indicator"
        "blueman-applet"
        "swww-daemon && swww img ~/Pictures/wallpapers/mountain.jpg"
      ];

      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
        "col.active_border" = "0xffa6e3a1"; # Catppuccin green
        "col.inactive_border" = "0xff585b70";
      };

      decoration = {
        rounding = 8;
        blur = { enabled = true; size = 5; };
        shadow = { enabled = true; range = 10; };
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };

      bind = [
        # App launching
        "SUPER, Return, exec, kitty"
        "SUPER, D, exec, rofi -show drun"
        "SUPER, B, exec, thunar"
        "SUPER, W, exec, firefox"

        # Window management
        "SUPER, Q, killactive"
        "SUPER, M, exit"
        "SUPER, F, togglefloating"
        "SUPER, SPACE, fullscreen"

        # Workspace navigation
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, H, movefocus, l"
        "SUPER, L, movefocus, r"
        "SUPER, K, movefocus, u"
        "SUPER, J, movefocus, d"

        # Screenshots
        "SUPER, P, exec, grim -g \"$(slurp)\" - | wl-copy"

        # Brightness
        ", XF86MonBrightnessUp, exec, brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"

        # Audio controls
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
    };
  };

  # Waybar setup
  programs.waybar = {
    enable = true;
    style = ''
      * {
        font-family: "JetBrains Mono", monospace;
        font-size: 12px;
        color: #cdd6f4;
      }
      window#waybar {
        background-color: rgba(30, 30, 46, 0.85);
        border-bottom: 2px solid #a6e3a1;
      }
      #workspaces button.active {
        color: #a6e3a1;
      }
      #clock, #battery, #network, #bluetooth, #pulseaudio {
        margin: 0 8px;
      }
    '';
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [ "workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "network" "bluetooth" "pulseaudio" "battery" ];
      };
    };
  };
}
