__ui_default_pager() {
  if _dep_ch bat; then
    bat --paging=always --theme=TwoDark --color=always
  elif _dep_ch gum; then
    # shellcheck disable=SC2086
    gum pager $CONFIG_GUM_PAGER_OPTS
  elif _dep_ch less; then
    less -R
  else
    more
  fi
}

__ui_rofi_pager() {
  ! [ -s "$CONFIG_ROFI_THEME_PAGER" ] && ui_notify_critical "$TXT_ROFI_NOT_CONFIGURED: where CONFIG_ROFI_THEME_PAGER=\"$CONFIG_ROFI_THEME_PAGER\""

  rofi -no-config -theme "$CONFIG_ROFI_THEME_PAGER" -dmenu -i -mesg "$TXT_ROFI_PAGER_MESSAGE" -p "$TXT_ROFI_PAGER_PROMPT"
}

_ui_pager() {
  case "$CONFIG_LAUNCHER" in
  rofi) __ui_rofi_pager ;;
  *) __ui_default_pager ;;
  esac
}

ui_pager() {
  _ui_pager
}
