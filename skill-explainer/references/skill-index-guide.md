# Skill Index Guide

How to scan and interpret locally installed skills.

## Skill Locations

Skills are stored in:
```
~/.claude/skills/           # Main skill directory
~/.my-skills/skills/        # User custom skills (often symlinked)
```

Some directories in `~/.claude/skills/` are symlinks pointing elsewhere.

## What to Scan

For each skill directory, read ONLY the frontmatter of `SKILL.md`:
```yaml
---
name: skill-name
description: "做什么 + 触发场景 + 不处理什么"
---
```

The `description` field is the primary matching surface. It tells you:
1. What the skill does
2. When it triggers
3. What it explicitly does NOT handle

## Sub-Skill Structure

Some skills use `parent/child` structure:
```
game-publisher/
├── SKILL.md              # orchestrator description
├── init/SKILL.md         # game-publisher/init
├── generate/SKILL.md     # game-publisher/generate
└── ...
```

Sub-skills have their own frontmatter. Include them in search results when relevant.

## Chain Skills

Chain skills (parent with sub-skills) should be presented as a complete workflow:
```
game-publisher
  → game-publisher/init
  → game-publisher/generate
  → game-publisher/verify
  → game-publisher/ship
  → game-publisher/handbook
```

If user's need matches one step, show the whole chain for context.

## What NOT to Include

Skip these when presenting results:
- Skills with `hidden: true` in frontmatter (internal/utility skills)
- Skills whose description starts with "Deprecated"
- Symlinks pointing to non-existent directories
- Skills the user has explicitly disabled
