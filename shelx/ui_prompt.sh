__ui_default_prompt() {
  local header
  local value
  header="$2"

  if _dep_ch gum; then
    # shellcheck disable=SC2086
    gum input $CONFIG_GUM_INPUT_OPTS --header "$header" --prompt "$1: "
  else
    printf "%s\n" "$header" >/dev/stderr
    printf "%s: " "$1" >/dev/stderr
    read -r value
    printf "%s" "$value"
  fi
}

__ui_rofi_prompt() {
  local default
  local filter

  if [ -p /dev/stdin ]; then
    default="$(cat 2>/dev/null)"
    filter='-filter'
  fi

  [ -s "$CONFIG_ROFI_THEME_PROMPT" ] ||
    ui_notify_critical "Rofi prompt theme not set: $CONFIG_ROFI_THEME_PROMPT"

  # NOTE: It doesnt look pretty so disabling it
  if [ -n "$2" ] && false; then
    # shellcheck disable=SC2086
    rofi -no-config -theme "$CONFIG_ROFI_THEME_PROMPT" "$filter" "$default" -dmenu -p "$1" -mesg "$2"
  else
    # shellcheck disable=SC2086
    rofi -no-config -theme "$CONFIG_ROFI_THEME_PROMPT" "$filter" "$default" -dmenu -p "$1"
  fi
}

_ui_prompt() {
  case "$CONFIG_LAUNCHER" in
  rofi) __ui_rofi_prompt "$@" ;;
  *) __ui_default_prompt "$@" ;;
  esac
}

ui_prompt() {
  _ui_prompt "$@"
}
