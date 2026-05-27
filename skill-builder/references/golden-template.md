# Golden Template Reference

The authoritative format for all skills. This is the pattern every generated skill must follow.

## Three Layers (Progressive Disclosure)

```
Layer 1: frontmatter (~100 tokens)
    ↑ Loaded at startup for ALL skills. Must be precise.
Layer 2: SKILL.md body (~3000 tokens)
    ↑ Loaded when Claude decides to invoke this skill.
Layer 3: references/*.md (on-demand)
    ↑ Loaded only when Claude needs specific details.
```

## Layer 1: Frontmatter

```yaml
---
name: skill-name
description: "做什么 + 触发场景 + 不处理什么。三句话就是 SKILL 的招牌。"
---
```

Rules:
- description 写得越精确，Claude 选得越准
- "不处理什么" 同样重要——防止误触发
- name 用 kebab-case，关联 skills 用前缀: `game-publisher/init`
- 中文描述 OK，但触发关键词尽量中英文都覆盖

### Good Examples
```
description: 处理 MicroSaaS 用户邮件，识别邮件类型并起草回复。触发场景：用户邮件涉及订阅、退款、bug 反馈、功能咨询、合作邀约。不处理：涉及金额超 50 美元、含 lawyer/chargeback/legal 等敏感词的邮件。
```

```
description: 从零到上线发布一个 HTML5 小游戏站。触发场景：用户给了一个 HTML5 游戏 CDN 链接，想做成独立游戏站在线运营。会自动拆成 init → generate → verify → ship → handbook 五个阶段串行执行。
```

### Bad Examples
```
description: 一个很棒的客服 skill
description: Helps with emails
description: 处理事情
```

## Layer 2: SKILL.md Body

Maximum ~100 lines. Structure:

```markdown
# Skill Title

## 你是谁
One sentence. Role + responsibility boundary.

## 触发条件
When to activate. Be specific about keywords, user intent, and context.

## 工作流程
Numbered steps. Each step = one action. Clear input/output per step.

## 共享资源 (if multi-skill)
| 文件 | 用途 | 加载时机 |
|------|------|---------|

## 红线 (non-negotiable rules)
- Hard constraints that must never be violated
- Safety boundaries
- Quality gates
```

Rules:
- 骨架，不是肉——只描述流程，不堆细节
- 每个步骤一个动作，输入输出明确
- 红线写清楚什么绝对不能做

## Layer 3: references/

Each reference file covers ONE topic. Named clearly:
```
references/
├── classification-rules.md    # 分类判断标准
├── tone-guide.md              # 语气指南
├── refund-policy.md           # 退款政策
└── red-lines.md               # 红线详情
```

Rules:
- 每个文件一个主题
- 文件名描述内容，不是序号（❌ `ref-01.md`, ✅ `tone-guide.md`）
- SKILL.md 中引用: `references/xxx.md`

## templates/

Output templates. SKILL.md references them, fills variables at runtime:
```
templates/
├── refund-decline.md          # 退款婉拒模板
├── refund-approve.md          # 退款同意模板
└── bug-acknowledge.md         # bug 接收回复
```

## Chain Rule: One Skill Does One Thing

如果一个 SKILL 做 3 件以上的事 → 拆成链。

```
❌ game-publisher/SKILL.md  # 500 lines, does everything
✅ game-publisher/
   ├── SKILL.md             # orchestrator, 60 lines
   ├── init/SKILL.md        # one job: collect info
   ├── generate/SKILL.md    # one job: generate code
   ├── verify/SKILL.md      # one job: quality check
   ├── ship/SKILL.md        # one job: push to git
   └── handbook/SKILL.md    # one job: generate manual
```

Chain state: pass via JSON file in project/work directory.
Each step reads → acts → writes updated state.
