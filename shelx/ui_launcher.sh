__ui_gum_launcher() {
  local custom_opts
  local multi_select
  multi_select="$2"

  [ "$multi_select" = "multi" ] && custom_opts="--no-limit"
  [ -n "$CONFIG_FZF_HEADER" ] && custom_opts="$custom_opts --header $CONFIG_FZF_HEADER"

  local old_ifs
  old_ifs="$IFS"
  IFS=" "

  # shellcheck disable=SC2086
  gum filter $CONFIG_GUM_FILTER_OPTS --prompt="${1}: " $custom_opts

  IFS="$old_ifs"
}

__ui_fzf_launcher() {
  local custom_opts
  local multi_select
  multi_select="$2"

  [ "$multi_select" = "multi" ] && custom_opts="--multi"
  [ -n "$CONFIG_FZF_HEADER" ] && custom_opts="$custom_opts --header-first --header=$CONFIG_FZF_HEADER"

  # TODO: is there a better way to do this
  local old_ifs
  old_ifs="$IFS"
  IFS=" "

  # shellcheck disable=SC2086
  fzf --prompt="${1}: " $custom_opts

  IFS="$old_ifs"
}

__ui_rofi_launcher() {
  ! [ -s "$CONFIG_ROFI_THEME_MAIN" ] && ui_notify_critical "$TXT_ROFI_NOT_CONFIGURED: where CONFIG_ROFI_THEME_MAIN=\"$CONFIG_ROFI_THEME_MAIN\""
  local selection
  local custom_opts
  local multi_select
  local line

  multi_select="$2"
  [ "$multi_select" = "multi" ] && custom_opts="-multi-select"

  # shellcheck disable=SC2086
  selection=$(
    sed -E "s/$THEME_ESC(\[[0-9;]*[a-zA-Z]|\(B)//g" |
      rofi -no-config -theme "$CONFIG_ROFI_THEME_MAIN" -dmenu -i $custom_opts -p "$1"
  )
  printf '%s' "$selection"
}

_ui_launcher() {
  case "$CONFIG_LAUNCHER" in
  rofi) __ui_rofi_launcher "$@" ;;
  fzf) __ui_fzf_launcher "$@" ;;
  gum) __ui_gum_launcher "$@" ;;
  *) ui_notify_critical "$TXT_LAUNCHER_UNKNOWN: $CONFIG_LAUNCHER" ;;
  esac
}

ui_launcher() {
  _ui_launcher "$@"
}
