_ui_default_confirm() {
  local yes
  local no
  local default
  local default_index

  yes="${3:-$TXT_YES}"
  no="${4:-$TXT_NO}"
  default="${2:-$no}"

  if [ "$default" = "$yes" ]; then
    default_index=1
  else
    default_index=0
  fi

  if _dep_ch gum; then
    # shellcheck disable=SC2086
    gum confirm "$1" --default="$default_index" --affirmative="$yes" --negative="$no" $CONFIG_GUM_CONFIRM_OPTS
  else
    printf "%s ($yes/$no; $TXT_CONFIRM_DEFAULT: $default): " "$1" >/dev/stderr
    read -r CONFIRMED
    case "$CONFIRMED" in
    "$yes")
      return 0
      ;;
    "$no")
      return 1
      ;;
    *)
      if [ "$default" = "$yes" ]; then
        return 0
      else
        return 1
      fi
      ;;
    esac
  fi
}

_ui_rofi_confirm() {
  ! [ -s "$CONFIG_ROFI_THEME_CONFIRM" ] && ui_notify_critical "$TXT_ROFI_NOT_CONFIGURED: where CONFIG_ROFI_THEME_CONFIRM=\"$CONFIG_ROFI_THEME_CONFIRM\""
  local yes
  local no
  local default
  local default_index
  local selection

  yes="${3:-$TXT_YES}"
  no="${4:-$TXT_NO}"
  default="${2:-$no}"

  if [ "$default" = "$yes" ]; then
    default_index=0
  else
    default_index=1
  fi

  selection="$(printf "%s\n%s" "$yes" "$no" |
    rofi -no-config -theme "$CONFIG_ROFI_THEME_CONFIRM" -dmenu -i -p "$1" -selected-row "$default_index")"
  [ "$selection" = "$yes" ] && return 0 || return 1
}

_ui_confirm() {
  case "$CONFIG_LAUNCHER" in
  rofi) _ui_rofi_confirm "$@" ;;
  *) _ui_default_confirm "$@" ;;
  esac
}

ui_confirm() {
  _ui_confirm "$@"
}
