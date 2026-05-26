__player_tplay() {
  local url
  local mode
  local opts
  local tplay_cmd

  mode="$2"
  opts="$CONFIG_TPLAY_ARGS"

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

    if _dep_ch tplay; then
      tplay_cmd="tplay"
    else
      ui_notify_critical "$TXT_PLAYER_NOT_FOUND"
    fi

    # shellcheck disable=SC2086
    $tplay_cmd "$url" $opts
    ;;
  esac

  # shellcheck disable=SC2181
  if [ "$?" = "0" ]; then
    clear
  fi
}
