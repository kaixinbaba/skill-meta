#!/usr/bin/env bash
set -euo pipefail

# skill-meta installer — one command to install all 3 meta skills
# Usage:
#   ./install.sh              # interactive
#   ./install.sh --yes        # non-interactive, all defaults
#   ./install.sh --dir PATH   # custom install dir
#   ./install.sh status       # show status
#   ./install.sh uninstall    # remove all meta skill symlinks + copies

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_INSTALL_DIR="$HOME/.my-skills/skills"
INSTALL_DIR="$DEFAULT_INSTALL_DIR"
SKILLS=("skill-builder" "skill-explainer" "skill-migrate")

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

get_tool_skill_paths() {
  case "$1" in
    claude)   echo "$HOME/.claude/skills" ;;
    codex)    echo "$HOME/.codex/skills" ;;
    openclaw) echo "$HOME/.openclaw/workspace/skills"
              echo "$HOME/.openclaw/workspace/.agents/skills" ;;
    gemini)   echo "$HOME/.gemini/skills" ;;
  esac
}

detect_tools() {
  local tools=()
  for tool in claude codex openclaw gemini; do
    local dir
    dir=$(get_tool_skill_paths "$tool" | head -1)
    if [ -d "$(dirname "$dir")" ]; then
      tools+=("$tool")
    fi
  done
  echo "${tools[@]}"
}

cmd_install() {
  local non_interactive="${1:-false}"

  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}     skill-meta installer — 3 meta skills                ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""

  # Validate source
  for skill in "${SKILLS[@]}"; do
    if [ ! -f "$SCRIPT_DIR/$skill/SKILL.md" ]; then
      log_error "$skill/SKILL.md not found. Run from skill-meta repo root."
      return 1
    fi
  done

  # Custom dir
  if ! $non_interactive; then
    echo "  Install directory (default: $DEFAULT_INSTALL_DIR)"
    echo "  Enter path or press Enter for default:"
    read -r custom_dir
    if [ -n "$custom_dir" ]; then
      INSTALL_DIR="$custom_dir"
    fi
  fi

  echo ""
  log_info "Install dir: $INSTALL_DIR"
  echo ""

  # Install each skill
  for skill in "${SKILLS[@]}"; do
    local target="$INSTALL_DIR/$skill"

    if [ -e "$target" ] || [ -L "$target" ]; then
      log_warn "$skill: already exists, overwriting..."
      rm -rf "$target"
    fi

    mkdir -p "$target"
    cp -r "$SCRIPT_DIR/$skill/"* "$target/"
    log_success "$skill: copied → $target"
  done

  # Create symlinks
  echo ""
  local tools
  tools=($(detect_tools))

  if [ ${#tools[@]} -eq 0 ]; then
    log_warn "No AI tools detected"
    echo "  Supported: claude, codex, openclaw, gemini"
    echo "  Manually create symlinks:"
    for skill in "${SKILLS[@]}"; do
      echo "  ln -s $INSTALL_DIR/$skill ~/.claude/skills/$skill"
    done
  else
    for tool in "${tools[@]}"; do
      while IFS= read -r link_dir; do
        mkdir -p "$link_dir"
        for skill in "${SKILLS[@]}"; do
          local link_path="$link_dir/$skill"
          if [ -e "$link_path" ] || [ -L "$link_path" ]; then
            if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$INSTALL_DIR/$skill" ]; then
              continue  # already correct
            fi
            rm -rf "$link_path"
          fi
          ln -s "$INSTALL_DIR/$skill" "$link_path"
        done
        log_success "$tool: 3 symlinks → $link_dir"
      done < <(get_tool_skill_paths "$tool")
    done
  fi

  echo ""
  log_success "Done. 3 meta skills installed: ${SKILLS[*]}"
  echo ""
  echo "  Try: skill-builder  — create new skill from golden template"
  echo "       skill-explainer — find matching skills"
  echo "       skill-migrate  — consolidate skills across tools"
}

cmd_status() {
  echo ""
  echo -e "${CYAN}═══ skill-meta status ═══${NC}"
  echo ""

  for skill in "${SKILLS[@]}"; do
    local installed="$INSTALL_DIR/$skill"
    if [ -d "$installed" ] && [ -f "$installed/SKILL.md" ]; then
      echo -e "  ${GREEN}✓${NC} $skill → $installed"
    else
      echo -e "  ${RED}✗${NC} $skill (not installed)"
    fi
  done

  echo ""
  echo "Tool symlinks:"
  for tool in $(detect_tools); do
    echo "  $tool:"
    while IFS= read -r link_dir; do
      echo "    $link_dir:"
      for skill in "${SKILLS[@]}"; do
        local link_path="$link_dir/$skill"
        if [ -L "$link_path" ]; then
          echo -e "      ${GREEN}✓${NC} $skill → $(readlink "$link_path")"
        else
          echo -e "      ${RED}✗${NC} $skill"
        fi
      done
    done < <(get_tool_skill_paths "$tool")
  done
  echo ""
}

cmd_uninstall() {
  echo ""
  log_warn "This will remove:"
  echo "  - $INSTALL_DIR/skill-builder"
  echo "  - $INSTALL_DIR/skill-explainer"
  echo "  - $INSTALL_DIR/skill-migrate"
  echo "  - All symlinks from Claude/Codex/OpenClaw/Gemini skills dirs"

  read -p "  Confirm uninstall? (y/N): " -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Cancelled"
    return 0
  fi

  echo ""

  # Remove symlinks
  for tool in $(detect_tools); do
    while IFS= read -r link_dir; do
      for skill in "${SKILLS[@]}"; do
        local link_path="$link_dir/$skill"
        if [ -L "$link_path" ]; then
          rm "$link_path"
          log_success "Removed symlink: $link_dir/$skill"
        fi
      done
    done < <(get_tool_skill_paths "$tool")
  done

  # Remove installed dirs
  for skill in "${SKILLS[@]}"; do
    if [ -d "$INSTALL_DIR/$skill" ]; then
      rm -rf "$INSTALL_DIR/$skill"
      log_success "Removed: $INSTALL_DIR/$skill"
    fi
  done

  echo ""
  log_success "Uninstall complete"
}

show_help() {
  cat <<EOF
skill-meta installer — install 3 meta skills at once

Usage: ./install.sh [command] [flags]

Commands:
  install     Interactive install (default)
  status      Show installation status
  uninstall   Remove all meta skills

Flags:
  --yes       Non-interactive, use defaults
  --dir PATH  Custom install directory (default: $DEFAULT_INSTALL_DIR)

Supported tools: claude, codex, openclaw (2 paths), gemini

Examples:
  ./install.sh                        # interactive
  ./install.sh --yes                  # quick install with defaults
  ./install.sh --dir ~/custom/skills  # custom path
  ./install.sh status                 # check status
EOF
}

# ── Main ──────────────────────────────────────────────
COMMAND="install"
NON_INTERACTIVE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|-y) NON_INTERACTIVE=true; shift ;;
    --dir) INSTALL_DIR="$2"; shift 2 ;;
    --help|-h) show_help; exit 0 ;;
    install|status|uninstall) COMMAND="$1"; shift ;;
    *) log_error "Unknown: $1"; show_help; exit 1 ;;
  esac
done

case "$COMMAND" in
  install)   cmd_install "$NON_INTERACTIVE" ;;
  status)    cmd_status ;;
  uninstall) cmd_uninstall ;;
esac
