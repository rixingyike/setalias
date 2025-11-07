#!/usr/bin/env bash
set -euo pipefail

# Cross-platform setup script for setalias
# - Installs aliases into the appropriate shell profile (bash/zsh)
# - Creates symlinks (or copies) for helper scripts into $HOME
# - Configures a project root used by new.sh and post.sh

# Resolve repo paths
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR="$SCRIPT_DIR"
SCRIPTS_DIR="$REPO_DIR/scripts"

# Defaults
DEFAULT_PROJECT_ROOT="$HOME/work/yishulun_blog_mdandcode"
SETALIAS_DIR="$HOME/.setalias"
# Hidden RC file in HOME that will be sourced by user profile
ALIASES_FILE="$HOME/.setaliasrc"

# Parse args
PROJECT_ROOT="${1:-}"
if [[ -n "$PROJECT_ROOT" ]]; then
  # allow usage: ./setup.sh /path/to/project_root
  :
else
  # allow flag: --project-root PATH or -p PATH
  PROJECT_ROOT="${SETALIAS_PROJECT_ROOT:-}"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--project-root)
        PROJECT_ROOT="$2"; shift 2;;
      --)
        shift; break;;
      *)
        shift;;
    esac
  done
fi

if [[ -z "$PROJECT_ROOT" ]]; then
  PROJECT_ROOT="$DEFAULT_PROJECT_ROOT"
fi

ensure_dir() {
  mkdir -p "$1"
}

safe_link_or_copy() {
  local src="$1" dst="$2"
  # Always copy to $HOME to avoid symlink issues across platforms
  cp -f "$src" "$dst"
  # Ensure executable permission so aliases can invoke scripts directly
  chmod +x "$dst" 2>/dev/null || true
}

detect_profile_file() {
  # Decide which shell profile to modify
  local profile=""
  case "${OSTYPE:-}" in
    darwin*)
      # macOS defaults to zsh
      if [[ "${SHELL:-}" == *"zsh"* ]]; then
        profile="$HOME/.zshrc"
      else
        # fallback to bashrc or bash_profile
        if [[ -f "$HOME/.bashrc" ]]; then profile="$HOME/.bashrc"; else profile="$HOME/.bash_profile"; fi
      fi
      ;;
    linux*)
      # Linux: use bashrc
      profile="$HOME/.bashrc"
      ;;
    msys*|cygwin*)
      # Git Bash/MSYS/Cygwin
      profile="$HOME/.bashrc"
      ;;
    *)
      # default to bashrc
      profile="$HOME/.bashrc"
      ;;
  esac
  echo "$profile"
}

write_aliases_rc() {
  # Write a hidden rc file containing config, then append alias template if present
  printf "# setalias configuration and shortcuts (auto-generated)\n" > "$ALIASES_FILE"
  printf "SETALIAS_PROJECT_ROOT=\"%s\"\n\n" "$PROJECT_ROOT" >> "$ALIASES_FILE"

  local template="$SCRIPTS_DIR/.setaliasrc"
  if [ -f "$template" ]; then
    cat "$template" >> "$ALIASES_FILE"
  else
    cat >> "$ALIASES_FILE" <<'EOF'
# Aliases
alias fetch="$HOME/.fetch.sh"
alias new="$HOME/.new.sh"
alias open="$HOME/.open.sh"
alias post="$HOME/.post.sh"
alias push="$HOME/.push.sh"
alias pull="$HOME/.pull.sh"
alias loginwifi="$HOME/.loginwifi.sh"
EOF
  fi
}

inject_source_line() {
  local profile_file="$1"
  ensure_dir "$(dirname "$profile_file")"
  touch "$profile_file"
  local source_line="[ -f \"$ALIASES_FILE\" ] && source \"$ALIASES_FILE\""
  # idempotent append
  if ! grep -Fq "$ALIASES_FILE" "$profile_file"; then
    printf "\n# setalias: load custom shortcuts\n%s\n" "$source_line" >> "$profile_file"
  fi
}

link_scripts_into_home() {
  safe_link_or_copy "$SCRIPTS_DIR/.fetch.sh" "$HOME/.fetch.sh"
  safe_link_or_copy "$SCRIPTS_DIR/.new.sh" "$HOME/.new.sh"
  safe_link_or_copy "$SCRIPTS_DIR/.open.sh" "$HOME/.open.sh"
  safe_link_or_copy "$SCRIPTS_DIR/.post.sh" "$HOME/.post.sh"
  safe_link_or_copy "$SCRIPTS_DIR/.pull.sh" "$HOME/.pull.sh"
  safe_link_or_copy "$SCRIPTS_DIR/.push.sh" "$HOME/.push.sh"
  safe_link_or_copy "$SCRIPTS_DIR/.loginwifi.sh" "$HOME/.loginwifi.sh"
}

maybe_reload_profile() {
  local profile_file="$1"
  # Attempt to reload profile and aliases for immediate availability.
  # Note: this affects only the current shell process; if setup.sh is executed
  # as a standalone script, your parent shell won't inherit these changes.
  # For immediate effect in the current shell, run: source ./setup.sh
  if [[ -f "$profile_file" ]]; then
    # shellcheck disable=SC1090
    . "$profile_file" || true
  fi
  if [[ -f "$ALIASES_FILE" ]]; then
    # shellcheck disable=SC1090
    . "$ALIASES_FILE" || true
  fi
}

main() {
  printf "\n[setalias] Starting setup...\n"
  write_aliases_rc
  link_scripts_into_home
  local profile
  profile=$(detect_profile_file)
  inject_source_line "$profile"
  maybe_reload_profile "$profile"

  printf "[setalias] Configured project root: %s\n" "$PROJECT_ROOT"
  printf "[setalias] Aliases rc file: %s\n" "$ALIASES_FILE"
  printf "[setalias] Shell profile updated: %s\n" "$profile"
  printf "[setalias] Scripts linked under: %s\n\n" "$HOME"
  printf "Usage:\n  new \"标题\"\n  post\n  fetch\n  push \"commit message\"\n  pull\n  open /path/to/file.md\n  loginwifi [card] [password]\n\n"
}

main "$@"
