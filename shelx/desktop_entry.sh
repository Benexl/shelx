_app_generate_desktop_entry() {
  local entry

  if ui_confirm "$TXT_DESKTOP_ENTRY_PROMPT" "$TXT_LAUNCHER_LABEL_ROFI" "$TXT_LAUNCHER_LABEL_ROFI" "$TXT_LAUNCHER_LABEL_FZF"; then
    entry="\
[Desktop Entry]
Name=$CLI_NAME
Type=Application
Version=$CLI_VERSION
Path=$HOME
Comment=$TXT_DESKTOP_ENTRY_COMMENT
Terminal=false
Exec=$CLI_PATH --launcher rofi --no-disown-player
Categories=Entertainment"
  else
    entry="\
[Desktop Entry]
Name=$CLI_NAME
Type=Application
Version=$CLI_VERSION
Path=$HOME
Comment=$TXT_DESKTOP_ENTRY_COMMENT
Terminal=true
Exec=$CLI_PATH --launcher fzf
Categories=Entertainment"
  fi

  printf "%s\n" "$entry"
  exit 0
}
