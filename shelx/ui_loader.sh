__ui_default_loader() {
  local cmd
  cmd="$*"

  if _dep_ch gum; then
    # shellcheck disable=SC2086
    gum spin $CONFIG_GUM_SPIN_OPTS --show-output -- $cmd
  else
    printf '%s\n' "$TXT_LOADING" >/dev/stderr
    $cmd
  fi

}

__ui_rofi_loader() {
  local cmd
  cmd="$*"

  ui_notify "$TXT_LOADING"
  $cmd
}

_ui_loader() {
  case "$CONFIG_LAUNCHER" in
  rofi) __ui_rofi_loader "$@" ;;
  *) __ui_default_loader "$@" ;;
  esac
}

ui_load() {
  _ui_loader "$@"
}
