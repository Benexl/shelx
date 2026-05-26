#!/usr/bin/env sh
# shellcheck disable=SC3043,SC2034,SC1090
# shelx - posix scripting template
# MIT License - Copyright (c) 2024-2026 Benexl

# ==============================================================================
# META
# ==============================================================================
readonly CLI_NAME="${SHELX_APP_NAME:-shelx}"
readonly CLI_ARGS="$*"
readonly CLI_APP_NAME="${SHELX_APP_NAME:-shelx}"
readonly CLI_VERSION="0.8.0"
readonly CLI_AUTHOR="Benexl"
readonly CLI_REPO_URL="https://github.com/Benexl/shelx"
readonly CLI_URL="https://raw.githubusercontent.com/Benexl/shelx/refs/heads/master/shelx"

# ==============================================================================
# SETUP
# ==============================================================================
# shellcheck disable=2155
readonly CLI_START_TIME="$(date +%s)"

_dep_ch() {
  command -v "$1" >/dev/null 2>&1
}

# ==============================================================================
# SETUP ENVIRONMENT
# ==============================================================================
if [ -n "$BASH_VERSION" ]; then
  readonly CLI_SHELL="bash"
elif [ -n "$ZSH_VERSION" ]; then
  readonly CLI_SHELL="zsh"
elif [ -n "$KSH_VERSION" ]; then
  readonly CLI_SHELL="ksh"
else
  readonly CLI_SHELL="sh"
fi

if ! _dep_ch local; then
  eval 'local() { unset -v $1; }'
fi

if _dep_ch realpath; then
  # shellcheck disable=SC2155
  readonly CLI_DIR="$(dirname "$(realpath "$0")")"
else
  # shellcheck disable=SC2155
  readonly CLI_DIR="$(cd "$(dirname "$0")" && pwd -P)"
fi

readonly CLI_PATH="$CLI_DIR/$CLI_NAME"

if [ "$CLI_SHELL" = "zsh" ]; then
  setopt shwordsplit
fi

case "$(uname -a)" in
*ndroid*) readonly CLI_PLATFORM="android" ;;
*Darwin*) readonly CLI_PLATFORM="mac" ;;
*WSL* | *microsoft* | *Microsoft*) readonly CLI_PLATFORM="linux" ;;
*MINGW* | *MSYS* | *CYGWIN*) readonly CLI_PLATFORM="windows" ;;
*) readonly CLI_PLATFORM="linux" ;;
esac

if [ -t 1 ]; then
  readonly CLI_IS_TERMINAL=true
else
  readonly CLI_IS_TERMINAL=false
fi

if [ "$COLORTERM" = "truecolor" ] || [ "$COLORTERM" = "24bit" ]; then
  readonly CLI_SUPPORTS_TRUE_COLOR=true
else
  readonly CLI_SUPPORTS_TRUE_COLOR=false
fi

export SHELL="sh"

# ==============================================================================
# SETUP PATHS
# ==============================================================================
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

readonly CLI_CONFIG_DIR="$XDG_CONFIG_HOME/$CLI_APP_NAME"

readonly CLI_CACHE_DIR="$XDG_CACHE_HOME/$CLI_APP_NAME"

readonly CLI_STATE_DIR="$CLI_CACHE_DIR/state"
readonly CLI_CURRENT_STATE_DIR="$CLI_STATE_DIR/${CLI_START_TIME}-$$"

readonly CLI_PREVIEW_DIR="$CLI_CACHE_DIR/previews"
readonly CLI_PREVIEW_IMGS_DIR="$CLI_PREVIEW_DIR/images"
readonly CLI_PREVIEW_SCRIPTS_DIR="$CLI_PREVIEW_DIR/text"
readonly CLI_FZF_PREVIEW_SCRIPT="$CLI_PREVIEW_SCRIPTS_DIR/fzf-preview.sh"

readonly CLI_CONFIG_FILE="$CLI_CONFIG_DIR/config"
readonly CLI_DEFAULT_THEME_FILE="$CLI_EXTENSIONS_THEMES_DIR/default.theme"
readonly CLI_DEFAULT_LANG_FILE="$CLI_EXTENSIONS_LANGS_DIR/default.lang"
readonly CLI_RECENT_FILE="$CLI_CONFIG_DIR/recent.json"
readonly CLI_SEARCH_HISTORY_FILE="$CLI_CACHE_DIR/search-history.txt"

mkdir -p \
  "$CLI_CONFIG_DIR" \
  "$CLI_CURRENT_STATE_DIR" \
  "$CLI_PREVIEW_IMGS_DIR" \
  "$CLI_PREVIEW_SCRIPTS_DIR"
