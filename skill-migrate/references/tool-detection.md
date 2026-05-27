# Tool Detection Guide

How to detect installed AI coding tools and their skill directories.

## Known Tool Paths

| Tool | Skill Dir | Config Dir |
|------|-----------|------------|
| Claude Code | `~/.claude/skills/` | `~/.claude/` |
| Codex | `~/.codex/skills/` | `~/.codex/` |
| Gemini CLI | `~/.gemini/skills/` | `~/.gemini/` |

## Detection Method

For each tool, check if the skills directory exists:

```bash
for tool in claude codex gemini; do
  dir="$HOME/.${tool}/skills"
  if [ -d "$dir" ]; then
    count=$(find "$dir" -maxdepth 1 \( -type d -o -type l \) ! -name '.' ! -name '.git' ! -name '.system' | wc -l | tr -d ' ')
    echo "  $tool: $count skills ($dir)"
  fi
done
```

## Classify Each Skill Entry

For each entry in a tool's skill directory, determine:
- **REAL** — actual directory with SKILL.md inside
- **LINK** — symlink pointing elsewhere
- **SYSTEM** — internal `.system` or `.git` — skip

```bash
# List real dirs
find "$dir" -maxdepth 1 -type d ! -name '.' ! -name '.git' ! -name '.system' -exec basename {} \; | sort

# List symlinks with targets
find "$dir" -maxdepth 1 -type l -exec sh -c 'echo "$(basename "$1") -> $(readlink "$1")"' _ {} \; | sort
```

## Cross-Platform Duplicate Detection

Find skills with the same name across tools:

```bash
{ ls -1 ~/.claude/skills/ 2>/dev/null; ls -1 ~/.codex/skills/ 2>/dev/null; ls -1 ~/.gemini/skills/ 2>/dev/null; } | \
  sed 's/ ->.*//' | sort | uniq -c | sort -rn | awk '$1 > 1'
```
