# Post-Migration Verification Checklist

Run every check after migration. Any failure = block and report.

## MUST PASS

### V1. No broken symlinks
```bash
find ~/.claude/skills ~/.codex/skills ~/.gemini/skills -maxdepth 1 -type l ! -exec test -e {} \; -print
```
Must return empty.

### V2. Target has no symlinks (all real)
```bash
find ~/.my-skills/skills -maxdepth 1 -type l
```
Must return empty (or only expected external links like `impeccable`).

### V3. Total skills count consistent
Tool dir symlink count + internal dirs (`.system`, `.git`) = total entries.
Compare pre- and post-migration counts.

### V4. Each tool dir is all symlinks
```bash
for tool in claude codex gemini; do
  real=$(find ~/.$tool/skills -maxdepth 1 -type d ! -name '.' ! -name '.git' ! -name '.system' ! -name 'skills' | wc -l)
  if [ "$real" -gt 0 ]; then echo "FAIL: ~/.$tool/skills still has $real real dir(s)"; fi
done
```

## SHOULD PASS

### V5. All target skills have SKILL.md
```bash
for d in ~/.my-skills/skills/*/; do
  if [ ! -f "$d/SKILL.md" ]; then echo "WARN: $(basename $d) missing SKILL.md"; fi
done
```

### V6. Frontmatter readable for all skills
```bash
for d in ~/.my-skills/skills/*/; do
  name=$(sed -n '/^---$/,/^---$/p' "$d/SKILL.md" 2>/dev/null | grep '^name:' | head -1)
  if [ -z "$name" ]; then echo "WARN: $(basename $d) has no name in frontmatter"; fi
done
```

## Report Format

```
## 迁移报告

| 平台 | 迁移前 | 迁移后 | 软链 | 实体 |
|------|--------|--------|------|------|
| Claude | N | N | N | 0 |
| Codex | N | N | N | 0 |
| Gemini | N | N | N | 0 |

### 去重处理
- skill-a: Claude 版本保留，Codex 副本删除
- ...

### 验证结果
- V1 断链: ✅/❌
- V2 目标纯净: ✅/❌
- V3 数量一致: ✅/❌
- V4 全软链: ✅/❌

迁移耗时: X 秒
```
