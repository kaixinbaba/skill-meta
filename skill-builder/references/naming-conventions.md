# Skill Naming Conventions

## Name Format

`kebab-case`, lowercase, no special chars except `/` for sub-skills.

```
single-skill:        "customer-email"
chain orchestrator:  "game-publisher"  
chain step:          "game-publisher/init"
```

## Name Rules

1. **Use verb-first for action skills**: `analyze-logs`, `send-email`, `generate-report`
2. **Use noun-first for domain skills**: `customer-email`, `game-publisher`, `code-review`
3. **Sub-skills use parent prefix**: `game-publisher/init`, `game-publisher/generate`
4. **No version numbers in names**: ❌ `email-v2`, ✅ handle version in description
5. **No abbreviations unless universally known**: ❌ `cust-eml-proc`, ✅ `customer-email`

## Name Length

- 2-3 words max
- 15-40 characters for the name field
- Sub-skill names shorter: the parent prefix already provides context

## Reserved Prefixes

These are common skill domains — check before naming:
- `seo:*` — SEO-related
- `plan:*` — planning/review skills  
- `design:*` — design-related
- `code:*` — code analysis/modification
- `qa:*` — testing/quality

## Directory Equals Name

The directory name under `~/.claude/skills/` IS the skill name:
```
~/.claude/skills/game-publisher/  →  skill name: "game-publisher"
```
