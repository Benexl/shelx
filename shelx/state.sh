__state_clean_prev() {
  local current_state_dir
  current_state_dir="$CLI_CURRENT_STATE_DIR/$STATE_CURRENT"
  ! [ -d "$current_state_dir" ] && ui_notify_critical "$TXT_STATE_MALFORMED_CURRENT"
  rm -rf "$current_state_dir"
}

_state_init() {
  STATE_CURRENT=0
}

_state_push() {
  local current_state_dir

  STATE_CURRENT="$((STATE_CURRENT + 1))"
  current_state_dir="$CLI_CURRENT_STATE_DIR/$STATE_CURRENT"
  mkdir -p "$current_state_dir"

  cat <<EOF >"$current_state_dir/state.env"
# state defs
EOF
}

_state_pop() {
  local current_state_dir
  local pop_count
  local i
  i=0
  pop_count="${1:-1}"

  [ "$pop_count" -le 0 ] && return

  while [ "$i" -lt "$pop_count" ]; do
    __state_clean_prev
    STATE_CURRENT="$((STATE_CURRENT - 1))"
    i=$((i + 1))
  done

  [ "$((STATE_CURRENT))" -lt 1 ] && return

  current_state_dir="$CLI_CURRENT_STATE_DIR/$STATE_CURRENT"
  ! [ -d "$current_state_dir" ] && ui_notify_critical "$TXT_STATE_MALFORMED_CURRENT"

  # shellcheck disable=SC1091
  . "$current_state_dir/state.env" || ui_notify_critical "$TXT_STATE_MALFORMED_CURRENT"
}
