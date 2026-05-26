# ==============================================================================
# CORE: utilities
# ==============================================================================
_util_terminal_exec() {
  local term
  local old_ifs
  local cmd
  cmd="$*"
  old_ifs="$IFS"

  if ! $CLI_IS_TERMINAL; then
    if [ -n "$CONFIG_TERMINAL_EXEC" ]; then
      term="$CONFIG_TERMINAL_EXEC"
    elif _dep_ch kitty; then
      term="kitty --exec"
    elif _dep_ch alacritty; then
      term="alacritty --command"
    else
      ui_notify_error "$TXT_NO_TERMINAL_EXEC"
      return 1
    fi
    IFS=" "
    # shellcheck disable=SC2086
    $term $cmd
    IFS="$old_ifs"
    return
  fi
  IFS=" "
  $cmd
  IFS="$old_ifs"
}

_util_open() {
  local target
  local converted_target
  target="$1"

  if _dep_ch open; then
    open "$target" || return 1
    return 0
  elif _dep_ch xdg-open; then
    xdg-open "$target" || return 1
    return 0
  elif _dep_ch wslview; then
    wslview "$target" || return 1
    return 0
  elif _dep_ch cmd.exe; then
    converted_target="$target"

    case "$target" in
    http://* | https://* | ftp://* | ftps://* | mailto:*) ;;
    *)
      if _dep_ch cygpath; then
        converted_target="$(cygpath -w "$target" 2>/dev/null || printf "%s" "$target")"
      elif _dep_ch wslpath; then
        converted_target="$(wslpath -w "$target" 2>/dev/null || printf "%s" "$target")"
      fi
      ;;
    esac

    cmd.exe /C start "" "$converted_target" >/dev/null 2>&1 || return 1
    return 0
  else
    return 1
  fi
}

_util_file_edit() {
  local file_path
  file_path="$1"

  if _dep_ch "$CONFIG_EDITOR"; then
    _util_terminal_exec "$CONFIG_EDITOR" "$file_path"
  elif _dep_ch "$EDITOR"; then
    _util_terminal_exec "$EDITOR" "$file_path"
  elif ! _util_open "$file_path"; then
    ui_notify_warning "$TXT_EDITOR_NOT_FOUND"
  fi
}

_util_generate_hash() {
  local input

  if [ -n "$1" ]; then
    input="$1"
  else
    input=$(cat)
  fi

  if _dep_ch sha256sum; then
    printf "%s" "$input" | sha256sum | awk '{print $1}'
  elif _dep_ch shasum; then
    printf "%s" "$input" | shasum -a 256 | awk '{print $1}'
  elif _dep_ch sha256; then
    printf "%s" "$input" | sha256 | awk '{print $1}'
  elif _dep_ch openssl; then
    printf "%s" "$input" | openssl dgst -sha256 | awk '{print $2}'
  else
    printf "%s" "$input" | base64 | tr '/+' '_-' | tr -d '\n'
  fi
}

_util_menu_sort() {
  # TODO: shift to using awk
  local options_to_sort
  local options_to_sort_copy
  local sort
  local i
  i=0
  options_to_sort="$1"
  sort="$2"

  for option in $(printf '%s' "$options_to_sort" | tr ' ' '-'); do
    i=$((i + 1))
    if [ -z "$options_to_sort_copy" ]; then
      options_to_sort_copy="$i:$option"
    else
      options_to_sort_copy="$options_to_sort_copy\n$i:$option"
    fi
  done

  for order in $(printf '%s' "$sort" | tr ',' '\n'); do
    printf "$options_to_sort_copy" | grep "^$order:" | sed "s/$order://g" | tr '-' ' '
  done
}

_util_byebye() {
  printf '%s %s\n' "$TXT_BYEBYE" "$USER"
  exit
}
