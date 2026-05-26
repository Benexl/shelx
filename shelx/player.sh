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

_play() {
  case "$CONFIG_PLAYER" in
  mpv) __player_mpv "$1" "$2" ;;
  vlc) __player_vlc "$1" "$2" ;;
  tplay) __player_tplay "$1" "$2" ;;
  *) ui_notify_critical "$TXT_PLAYER_NOT_FOUND" ;;
  esac
}

play() {
  _play "$@"
}
