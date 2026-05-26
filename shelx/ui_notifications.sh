__ui_notify_terminal() {
  #TODO: finish implementation
  case "$1" in
  info) printf '%s\n' "$2" >&2 && sleep "$CONFIG_NOTIFICATION_DURATION" ;;
  warning) printf '%s\n' "$2" >&2 && sleep "$CONFIG_NOTIFICATION_DURATION" ;;
  error) printf '%s\n' "$2" >&2 && sleep "$CONFIG_NOTIFICATION_DURATION" ;;
  critical) printf '%s\n' "$2" >&2 && exit 1 ;;
  *) printf '%s\n' "$2" >&2 && sleep "$CONFIG_NOTIFICATION_DURATION" ;;
  esac

}

__ui_notify_non_terminal() {
  #TODO: finish implementation
  case "$1" in
  info) notify-send "$2" ;;
  warning) notify-send "$2" ;;
  error) notify-send "$2" ;;
  critical) notify-send "$2" && exit 1 ;;
  esac
}

_ui_notify() {
  if $CLI_IS_TERMINAL; then
    __ui_notify_terminal info "$1"
  else
    __ui_notify_non_terminal info "$1"
  fi
}

_ui_notify_warning() {
  if $CLI_IS_TERMINAL; then
    __ui_notify_terminal warning "$1"
  else
    __ui_notify_non_terminal warning "$1"
  fi
}

_ui_notify_error() {
  if $CLI_IS_TERMINAL; then
    __ui_notify_terminal error "$1"
  else
    __ui_notify_non_terminal error "$1"
  fi
}

_ui_notify_critical() {
  if $CLI_IS_TERMINAL; then
    __ui_notify_terminal critical "$1"
  else
    __ui_notify_non_terminal critical "$1"
  fi
}

ui_notify() {
  _ui_notify "$@"
}

ui_notify_warning() {
  _ui_notify_warning "$@"
}

ui_notify_error() {
  _ui_notify_error "$@"
}

ui_notify_critical() {
  _ui_notify_critical "$@"
}
