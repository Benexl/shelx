_app_cmd_line_parser() {
  local shift_count
  while [ $# -gt 0 ]; do
    shift_count=1
    case "$1" in
    -h | --help) _app_usage ;;
    -v | --version) printf '%s v%s MIT Copyright © 2024 %s\n' "$CLI_NAME" "$CLI_VERSION" "$CLI_AUTHOR" && exit 0 ;;
    *) _app_usage 1 ;;
    esac
    shift $shift_count
  done
}
