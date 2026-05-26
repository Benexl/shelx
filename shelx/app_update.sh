_app_update_script() {
  local update

  if ! [ -w "$CLI_PATH" ]; then
    ui_confirm "$TXT_UPDATE_ROOT_WARNING" || exit 1
    if _dep_ch sudo; then
      exec sudo -s "$CLI_PATH" "-u"
    else
      ui_notify_critical "$TXT_UPDATE_SUDO_MISSING"
    fi
  fi

  update="$1"
  [ -z "$update" ] && ui_notify_critical "$TXT_UPDATE_FETCH_FAILED"

  if printf "%s" "$update" >"$CLI_PATH"; then
    rm "$CLI_FZF_PREVIEW_SCRIPT" >/dev/null 2>&1
    if ui_confirm "$TXT_UPDATE_SCRIPT_REEXECUTE"; then
      # shellcheck disable=SC2086
      exec "$CLI_PATH" $CLI_ARGS
    else
      exit 0
    fi
  else
    ui_notify_critical "$TXT_UPDATE_FAILED"
  fi
}

_app_update_check() {
  local update
  local is_update

  update=$(curl -s "$CLI_URL")
  [ -z "$update" ] && return 1

  is_update="$(printf "%s" "$update" | diff -u "$CLI_PATH" -)"

  if [ -n "$is_update" ]; then
    ui_confirm "$TXT_UPDATE_FOUND" && printf '%s' "$is_update" | ui_pager
    ui_confirm "$TXT_UPDATE_CONFIRM" && _app_update_script "$update"
  else
    return 1
  fi
}

_app_auto_update() {
  local timestamp_file
  local interval
  local last_check_time

  if [ "$CONFIG_CHECK_FOR_UPDATES" = "true" ]; then
    timestamp_file="$CLI_CACHE_DIR/.last_update_check"

    interval=$((12 * 60 * 60))

    last_check_time=$(cat "$timestamp_file" 2>/dev/null || printf '0')

    if [ "$((CLI_START_TIME - last_check_time))" -ge "$interval" ]; then
      _app_cache_clean_up &

      _app_update_check
      printf '%s' "$CLI_START_TIME" >"$timestamp_file"
    fi
  fi
}
