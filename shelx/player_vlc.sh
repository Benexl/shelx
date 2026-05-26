__player_vlc() {
  local url
  local mode
  local opts
  local vlc_cmd

  mode="$2"
  opts="$CONFIG_VLC_ARGS"

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
    nohup am start --user 0 -a android.intent.action.VIEW -d "$url" -n org.videolan.vlc/org.videolan.vlc.gui.video.VideoPlayerActivity -e "title" "$STATE_CURRENT_VIDEO_TITLE" >/dev/null 2>&1 &
    ;;
  *)
    url="$1"

    if _dep_ch vlc; then
      vlc_cmd="vlc"
    elif _dep_ch "vlc.exe"; then
      vlc_cmd="vlc.exe"
    else
      ui_notify_critical "$TXT_PLAYER_NOT_FOUND"
    fi

    if [ "$CONFIG_DISOWN_PLAYER" = "true" ]; then
      # shellcheck disable=SC2086
      nohup $vlc_cmd "$url" $opts &
    else
      # shellcheck disable=SC2086
      $vlc_cmd "$url" $opts
    fi
    ;;
  esac

  # shellcheck disable=SC2181
  if [ "$?" = "0" ]; then
    clear
  fi
}
