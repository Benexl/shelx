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

__preview_fzf_create_shared_script() {
  if ! [ -s "$CLI_FZF_PREVIEW_SCRIPT" ]; then
    cat <<'EOF' >"$CLI_FZF_PREVIEW_SCRIPT"
#!/usr/bin/env sh
# ==============================================================================
# Shared script for fzf previews
# ==============================================================================

draw_divider() {
  ll=1
  while [ $ll -le $FZF_PREVIEW_COLUMNS ];do printf "${THEME_FZF_PREVIEW_DIVIDER}─${THEME_RESET}" ;ll=$(( ll + 1 ));done;
  echo
}

fzf_preview() {
  file=$1

  dim=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}
  if [ "$dim" = "x" ]; then
    dim=$(stty size </dev/tty | awk "{print \$2 \"x\" \$1}")
  fi
  if ! [ "$CONFIG_IMAGE_RENDERER" = "icat" ] && [ -z "$KITTY_WINDOW_ID" ] && [ "$((FZF_PREVIEW_TOP + FZF_PREVIEW_LINES))" -eq "$(stty size </dev/tty | awk "{print \$1}")" ]; then
    dim=${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))
  fi

  if [ "$CONFIG_IMAGE_RENDERER" = "icat" ] && [ -z "$GHOSTTY_BIN_DIR" ]; then
    if command -v kitten >/dev/null 2>&1; then
      kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" "$file" | sed "\$d" | sed "$(printf "\$s/\$/\033[m/")"
    elif command -v icat >/dev/null 2>&1; then
      icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" "$file" | sed "\$d" | sed "$(printf "\$s/\$/\033[m/")"
    else
      kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" "$file" | sed "\$d" | sed "$(printf "\$s/\$/\033[m/")"
    fi

  elif [ -n "$GHOSTTY_BIN_DIR" ]; then
    if command -v kitten >/dev/null 2>&1; then
      kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" "$file" | sed "\$d" | sed "$(printf "\$s/\$/\033[m/")"
    elif command -v icat >/dev/null 2>&1; then
      icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" "$file" | sed "\$d" | sed "$(printf "\$s/\$/\033[m/")"
    else
      chafa -s "$dim" "$file"
    fi
  elif command -v chafa >/dev/null 2>&1; then
    case "$CLI_PLATFORM" in
    android) chafa -s "$dim" "$file" ;;
    windows) chafa -f sixel -s "$dim" "$file" ;;
    *) chafa -s "$dim" "$file" ;;
    esac
    echo

  elif command -v imgcat >/dev/null; then
    imgcat -W "${dim%%x*}" -H "${dim##*x}" "$file"

  else
    printf "%s" "$TXT_PREVIEW_INSTALL_VIEWER"
  fi
}
EOF
  else
    return
  fi
}
