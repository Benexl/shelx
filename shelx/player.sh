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
