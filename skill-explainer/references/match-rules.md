# Skill Matching Rules

How to match user needs against available skills.

## Match Algorithm

1. **Keyword overlap** (weight: 40%) — user's description words vs skill description words
2. **Domain match** (weight: 30%) — same domain/field (e.g., SEO, deployment, code review)
3. **Intent match** (weight: 20%) — same action verb (e.g., "deploy", "review", "analyze", "create")
4. **Exclusion check** (weight: 10%) — skill's "不处理" doesn't match what user wants — penalize

## Match Tiers

### Tier 1: Exact Match (score ≥ 0.9)
Skill description directly addresses user's stated need. Show first, bolded, with confidence: "这个最匹配".

### Tier 2: Partial Match (score 0.5–0.9)
Skill covers related territory but not exact. Show with caveat: "也可以看看，但不完全匹配".

### Tier 3: Loose Match (score < 0.5)
Mention only if user asks for more options. Otherwise skip.

## When No Match Found

If best score < 0.3:
- Tell user honestly: no installed skill matches
- Suggest: "可以用 skill-builder 自己建一个"
- Offer to search for similar skills in marketplace or web

## Special Cases

### Multiple skills match equally well
Present all, let user choose. Sort by skill freshness (most recently modified first).

### Chain skill matches
If user's need maps to a chain, show the orchestrator first, then explain the chain flow.

### User provides a URL or file
Extract domain/tool hint from the URL. Example: `cdn.htmlgames.com` → game-related → `game-publisher`.

### User mentions a specific tool
Match against skill references. Example: "wrangler" → check if any skill references Cloudflare/Pages.
