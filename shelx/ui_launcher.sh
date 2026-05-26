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

# ==============================================================================
# CORE UI: launcher with preview
# ==============================================================================
__ui_fzf_launcher_with_preview() {
  local custom_opts
  local multi_select
  local preview_script

  preview_script="\
TXT_PREVIEW_INSTALL_VIEWER='$TXT_PREVIEW_INSTALL_VIEWER'
CONFIG_IMAGE_RENDERER='$CONFIG_IMAGE_RENDERER'
CLI_PLATFORM='$CLI_PLATFORM'
THEME_FZF_PREVIEW_DIVIDER='$THEME_FZF_PREVIEW_DIVIDER'
preview_script_path='{1}'
[ -s \"\$preview_script_path\" ] && . \"\$preview_script_path\"\
"

  multi_select="$2"
  [ "$multi_select" = "multi" ] && custom_opts="--multi"
  [ -n "$CONFIG_FZF_HEADER" ] && custom_opts="$custom_opts --header-first --header=$CONFIG_FZF_HEADER"

  # TODO: is there a better way to do this
  local old_ifs
  old_ifs="$IFS"
  IFS=" "

  # shellcheck disable=SC2086
  fzf --prompt="${1}: " --delimiter '|' --with-nth "{2..}" --accept-nth "{2..}" --preview="$preview_script" $custom_opts

  IFS="$old_ifs"
}

__ui_rofi_launcher_with_preview() {
  ! [ -s "$CONFIG_ROFI_THEME_PREVIEW" ] && ui_notify_critical "$TXT_ROFI_NOT_CONFIGURED: where CONFIG_ROFI_THEME_PREVIEW=\"$CONFIG_ROFI_THEME_PREVIEW\""
  local selection
  local custom_opts
  local multi_select
  local line

  multi_select="$2"
  [ "$multi_select" = "multi" ] && custom_opts="-multi-select"

  # shellcheck disable=SC2086
  selection=$(
    sed -E "s/$THEME_ESC(\[[0-9;]*[a-zA-Z]|\(B)//g" |
      rofi -no-config -theme "$CONFIG_ROFI_THEME_PREVIEW" -dmenu -i $custom_opts -p "$1"
  )
  printf '%s' "$selection"
}

_ui_launcher_with_preview() {
  if [ "$CONFIG_ENABLE_PREVIEW" = "true" ]; then
    case "$CONFIG_LAUNCHER" in
    rofi) __ui_rofi_launcher_with_preview "$@" ;;
    fzf) __ui_fzf_launcher_with_preview "$@" ;;
    gum) __ui_gum_launcher "$@" ;;
    *) ui_notify_critical "$TXT_LAUNCHER_UNKNOWN: $CONFIG_LAUNCHER" ;;
    esac
  else
    ui_launcher "$@" && return
  fi
}

ui_launcher_with_preview() {
  _ui_launcher_with_preview "$@"
}
