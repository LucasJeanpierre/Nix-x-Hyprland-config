{ pkgs, ... }:

let
  wallpaperDir = "/home/zeta/nixos-conf/assets/wallpaper-time";

  applyWallpaperForElapsed = pkgs.writeShellScript "cosmic-wallpaper-apply" ''
    set -eu
    elapsed="$1"
    mapfile -t files < <(find "${wallpaperDir}" -maxdepth 1 -type f | sort -V)
    count=''${#files[@]}
    [ "$count" -eq 0 ] && { echo "No wallpapers found in ${wallpaperDir}" >&2; exit 1; }

    slot_length=$((86400 / count))
    index=$((elapsed / slot_length))
    if [ "$index" -ge "$count" ]; then index=$((count - 1)); fi
    wallpaper="''${files[$index]}"

    config_dir="/home/zeta/.config/cosmic/com.system76.CosmicBackground/v1"
    mkdir -p "$config_dir"
    cat > "$config_dir/all" <<RON
(
  output: "all",
  source: Path("$wallpaper"),
  filter_by_theme: true,
  rotation_frequency: 300,
  filter_method: Lanczos,
  scaling_mode: Zoom,
  sampling_method: Alphanumeric,
)
RON
  '';

  wallpaperScript = pkgs.writeShellScript "cosmic-wallpaper-by-time" ''
    set -eu
    midnight=$(date -d "today 00:00:00" +%s)
    now=$(date +%s)
    elapsed=$((now - midnight))
    exec ${applyWallpaperForElapsed} "$elapsed"
  '';

  wallpaperPreview = pkgs.writeShellScriptBin "wallpaper-preview" ''
    set -eu
    if [ $# -ne 1 ]; then
      echo "Usage: wallpaper-preview HH:MM" >&2
      exit 1
    fi
    target=$(date -d "today $1" +%s) || { echo "Invalid time: $1" >&2; exit 1; }
    midnight=$(date -d "today 00:00:00" +%s)
    elapsed=$((target - midnight))
    ${applyWallpaperForElapsed} "$elapsed"

    # Back to current wallpaper 30 seconds later
    systemctl --user reset-failed wallpaper-preview-revert.service 2>/dev/null || true
    systemd-run --user --on-active=30s --unit=wallpaper-preview-revert \
      --description="Revert to current-time wallpaper after preview" \
      -- ${wallpaperScript}
  '';
in
{
  environment.systemPackages = [ wallpaperPreview ];

  systemd.services.wallpaper-time-based = {
    description = "Set COSMIC wallpaper based on time of day";
    serviceConfig = {
      Type = "oneshot";
      User = "zeta";
      ExecStart = "${wallpaperScript}";
    };
    before = [ "cosmic-greeter-daemon.service" ];
    wantedBy = [ "cosmic-greeter-daemon.service" ];
  };

  systemd.timers.wallpaper-time-based = {
    description = "Re-check time-of-day wallpaper";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/15";
      Persistent = true;
      Unit = "wallpaper-time-based.service";
    };
  };
}
