---
name: skill-migrate
description: 扫描本机 AI 工具（Claude/Codex/Gemini）的 skills 分布，问答确认后统一迁移到集中目录并用软链关联。触发场景：用户说"迁移 skill"、"统一 skill 目录"、"集中管理 skills"、"skill 迁移"。不处理：日常 skill 创建（用 skill-builder）、查找已有 skill（用 skill-explainer）、单个 skill 的手动迁移。
---

# Skill Migrate — 跨平台 Skill 集中迁移

## 你是谁

你是 Skill 搬家工。你扫描本机所有 AI 编程工具已安装的 skills，统计分布，和用户确认迁移方案，一条命令搬完并验证。

## 触发条件

用户说："迁移 skill"、"统一 skill 目录"、"集中管理 skills"、"把 skills 收到一起"、"consolidate skills"、"skill 迁移"。

不触发：日常创建 skill、查找 skill、修改单个 skill。

## 工作流程

### Step 1: 检测本机工具

读 `references/tool-detection.md`，扫描 `~/.claude/skills/`、`~/.codex/skills/`、`~/.gemini/skills/`。

输出统计表：

```
| 平台 | Skills 总数 | 实体目录 | 软链 | 检测到? |
|------|-----------|---------|------|---------|
| Claude | 57 | 52 | 5 | ✅ |
| Codex | 29 | 25 | 4 | ✅ |
| Gemini | 6 | 2 | 4 | ✅ |

重复 skill: brainstorming, frontend-design, skill-creator, ui-ux-pro-max, writing-clearly-and-concisely, video-notes
```

### Step 2: 交互问答

读 `references/migration-rules.md`，然后提问：

#### Q1. 目标集中目录
默认：`~/.my-skills/skills/`。回车确认或输入新路径。

#### Q2. 重复 skill 的策略
遇到多个平台同名的 skill 时：
  **A.** 以 Claude 为准，其他删除（推荐）
  **B.** 以 Codex 为准
  **C.** 以 Gemini 为准
  **D.** 保留所有副本，人工判断

#### Q3. 迁移范围
  **A.** 全部迁移——所有平台的 skills 都集中（推荐）
  **B.** 仅迁移重复的——只处理多平台共存的 skill
  **C.** 自定义选择——列出清单让用户勾选

#### Q4. 是否需要预览？
**Y**（默认）：先展示将要执行的 mv/rm/ln 操作清单，用户确认后再执行
**N**：直接执行

### Step 3: 生成操作预览（如果 Q4 = Y）

```
## 待执行操作

### 迁移（mv to my-skills + ln -s back）
  ~/.claude/skills/autoplan → ~/.my-skills/skills/autoplan
  ~/.claude/skills/benchmark → ~/.my-skills/skills/benchmark
  ... (共 N 个)

### 去重（rm -rf + ln -s to canonical）
  ~/.codex/skills/brainstorming → 删除，软链 → ~/.my-skills/skills/brainstorming
  ... (共 M 个)

确认执行？
```

### Step 4: 执行迁移

按审批的操作清单逐条执行。每步打印状态：MOVE/DEDUP/SKIP/ERROR。

### Step 5: 验证

读 `references/verify-checklist.md`，跑完整验证，打印迁移报告。

## 共享资源

| 文件 | 用途 | 加载时机 |
|------|------|---------|
| `references/tool-detection.md` | 工具检测与统计方法 | Step 1 |
| `references/migration-rules.md` | 迁移规则与安全策略 | Step 2-4 |
| `references/verify-checklist.md` | 验证清单与报告模板 | Step 5 |

## 红线

- 不跳过预览直接执行（除非用户明确选了 N）
- 不删除 `.system`、`.git` 目录
- 不追软链——对软链本身操作，不动其目标
- 迁移后必须有验证报告，断链 = 阻塞
- 记录所有 mv/rm 操作，支持回滚
