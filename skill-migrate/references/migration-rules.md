# Migration Rules

## Core Principle

All skills live as real directories in `~/.my-skills/skills/` (single source of truth).
Each AI tool's skill directory contains only symlinks pointing there.

## Target Directory

Default: `~/.my-skills/skills/`
User may override via Q&A.

## Dedup Strategy

When the same skill name exists in multiple tools:

1. **User picks primary source** (default: Claude)
2. Keep the primary's version as canonical
3. Delete all other copies
4. All tools get symlinks to the canonical version

## Migration Steps

For each tool platform, for each skill entry:

1. **Already a symlink** → skip (already centralized or managed elsewhere)
2. **Real dir, name exists in target** → deduplicate: delete this copy, replace with symlink to target
3. **Real dir, name NOT in target** → `mv` to target, `ln -s` back from tool dir

## Safety Rules

- Never delete without confirmation (unless user pre-approved via Q&A)
- Never follow symlinks when moving — operate on the link itself, not target
- Check `impeccable` and similar external symlinks — don't migrate target, only the link
- `.system` and `.git` directories are never skills — always skip
- After migration: no broken symlinks allowed

## Rollback

If migration fails mid-way:
1. Target dir has the moved real dirs
2. Tool dirs may have partial symlinks
3. Recovery: `mv` real dirs back from target to original location, remove symlinks

Keep a log of every `mv` and `rm` operation so rollback is possible.
