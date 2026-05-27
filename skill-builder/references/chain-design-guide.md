# Chain Design Guide

When a skill handles 3+ distinct concerns, split into a chain.

## Detection: Count the Verbs

Look at the user's description. Count distinct action verbs:
- "收集信息然后生成代码再部署上线" → 3 verbs = 可能需要拆
- "分析代码给出建议" → 2 verbs = 单体 OK

## The 3-Verb Rule

```
≤2 verbs → single skill
≥3 verbs → propose chain split
```

## Chain Split Pattern

Each step = one SKILL.md. Steps connected by JSON state file.

### State File Convention
```json
{
  "skill_name": "user-auth",
  "status": {
    "phase": "setup",
    "step1_done": false,
    "step2_done": false
  }
}
```
Saved in project root or `.claude/state/`.

### Naming Convention
```
{parent}/
├── SKILL.md              # orchestrator
├── {step-1}/SKILL.md     # parent/step-1
├── {step-2}/SKILL.md     # parent/step-2
└── {step-3}/SKILL.md     # parent/step-3
```

### Step Frontmatter Pattern
```yaml
---
name: parent/step-name
description: 单一职责描述。触发场景：上一步完成后自动进入。下一步是 parent/next-step。
---
```

## When NOT to Split

- Steps are tightly coupled (step 2 needs in-memory context from step 1)
- Total workflow < 5 trivial steps
- No state needs to persist between steps
- User explicitly wants a single-file skill

## Signs You SHOULD Split

- SKILL.md > 150 lines
- references/ has > 5 files covering unrelated topics
- User describes workflow as "先...再...然后...最后..."
- Steps can fail independently and need retry
- Different steps need different permission levels
