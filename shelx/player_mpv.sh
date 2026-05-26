__player_mpv() {
  local url
  local mode
  local opts
  local mpv_cmd

  mode="$2"
  opts="$CONFIG_MPV_ARGS"

  case "$CLI_PLATFORM" in
  android)
    case "$mode" in
    listen)
      url="$(__fetch_audio_url "$1")"
      ;;
    *)
      url="$(__fetch_video_url "$1")"
      ;;
    esac
    nohup am start --user 0 -a android.intent.action.VIEW -d "$url" -n is.xyz.mpv/.MPVActivity >/dev/null 2>&1 &
    ;;
  *)
    url="$1"
    case "$mode" in
    listen)
      opts="$opts --no-video --force-window=no"
      ;;
    esac

    if _dep_ch mpv; then
      mpv_cmd="mpv"
    elif _dep_ch "mpv.exe"; then
      mpv_cmd="mpv.exe"
    else
      ui_notify_critical "$TXT_PLAYER_NOT_FOUND"
    fi

    if [ "$CONFIG_DISOWN_PLAYER" = "true" ]; then
      # shellcheck disable=SC2086
      nohup $mpv_cmd "$url" $opts &
    else
      # shellcheck disable=SC2086
      $mpv_cmd "$url" $opts
    fi
    ;;
  esac

  # shellcheck disable=SC2181
  if [ "$?" = "0" ]; then
    clear
  fi
}
