# requirements-skills

三份面向前端/产品需求交付流程的 AI Agent Skill：**写变更清单**、**写需求文档**、**做页面内文档阅读入口**。

适用于任何支持 `SKILL.md` 约定的 harness（Codex、Claude Code、DeepSeek Harness 等）。

## 包含什么

| Skill | 用途 | 典型触发 |
|---|---|---|
| [`change-list-authoring`](change-list-authoring/SKILL.md) | 编写、审查、正式化**可执行变更清单 / CR**：把需求或审查发现落实到任务、代码与文档落点、边界与验收。支持单仓与多仓。 | 「写变更清单」「审查这个 CR」「/cr」 |
| [`prd-rule-authoring`](prd-rule-authoring/SKILL.md) | 编写或更新 **PRD / 主页面规则明细 / 产品需求说明书（阅读层）**：先选文种与读者，再按完整性要求写作；横向规则建唯一权威与消费方矩阵；处理双轨维护、未定事项与证据。 | 「写 PRD」「补页面规则」「整理需求说明书」 |
| [`requirements-docs-viewer`](requirements-docs-viewer/SKILL.md) | 在应用内提供**需求文档阅读入口 / 查看器**：文档映射、构建期复制、目录与搜索、历史章节过滤、懒加载、生产暴露面处置。 | 「页面里加个需求文档入口」「文档抽屉」 |

## 三者边界

职责严格分工，**互不越界**：

```
prd-rule-authoring          文档内容怎么写（规则正文 / 阅读层）
        │
        │  只有「文档目录 + Markdown 约定」这一层耦合
        ▼
requirements-docs-viewer    文档怎么在页面里被读到（入口实现）

change-list-authoring       一次改动怎么被拆成可执行、可验收的任务
```

- `requirements-docs-viewer` 与两个写作技能**互不依赖**：没有阅读入口的项目也要产出需求文档；有阅读入口也不改变写作规则。
- 变更清单负责**范围、任务、验收与合并流程**；PRD 技能只负责**正文**。
- 每个技能都可在各自场景**单独使用**。

## 安装

把需要的技能目录复制或软链到 harness 的 skill 根目录。

**软链（推荐，便于随仓库更新）**

```bash
git clone https://github.com/xingbiyun-afk/requirements-skills.git ~/requirements-skills

# Codex
mkdir -p ~/.codex/skills
ln -sfn ~/requirements-skills/change-list-authoring        ~/.codex/skills/change-list-authoring
ln -sfn ~/requirements-skills/prd-rule-authoring           ~/.codex/skills/prd-rule-authoring
ln -sfn ~/requirements-skills/requirements-docs-viewer     ~/.codex/skills/requirements-docs-viewer

# Claude Code
mkdir -p ~/.claude/skills
ln -sfn ~/requirements-skills/prd-rule-authoring           ~/.claude/skills/prd-rule-authoring
# ……按需为每个技能建软链

# DeepSeek Harness
mkdir -p ~/.dsh/skills
ln -sfn ~/requirements-skills/prd-rule-authoring           ~/.dsh/skills/prd-rule-authoring
```

**复制**

```bash
cp -R ~/requirements-skills/{change-list-authoring,prd-rule-authoring,requirements-docs-viewer} ~/.codex/skills/
```

> ⚠️ **不要把备份目录放进任何 skill 根目录**。发现器会把 `<dir>/SKILL.md` 当成正式技能；与正式版同名时会抢过正式版。备份放到 skill 根之外，或把里面的 `SKILL.md` 改名。

## 结构

```
requirements-skills/
├── change-list-authoring/
│   ├── SKILL.md                  入口（触发条件、工作流程、质量门槛）
│   ├── CHANGELOG.md              版本记录
│   ├── agents/openai.yaml        agents 元信息
│   └── references/               按需加载的参考
│       ├── change-list-template.md
│       ├── review-method.md
│       ├── dual-repo-and-review.md
│       ├── rule-and-doc-impact.md
│       └── project-patterns.md
├── prd-rule-authoring/
│   ├── SKILL.md
│   ├── CHANGELOG.md
│   └── references/
│       ├── document-types.md          文种选择
│       ├── page-rule-spec.md          规则正文规格
│       ├── product-requirements-spec.md  阅读层规格
│       ├── cross-cutting-rules.md     横向规则
│       ├── projection-and-governance.md  双轨治理
│       ├── quality-checklist.md       完稿自审
│       └── batch-refactor-playbook.md 批量重构
│   └── archive/
│       └── v1-skill-20261023.md       v1 原文（回溯用，不加载）
└── requirements-docs-viewer/
    ├── SKILL.md
    ├── CHANGELOG.md
    └── references/
        ├── integration-design.md
        ├── rendering-and-search.md
        ├── acceptance-checklist.md
        └── ops-and-governance.md
```

每个 `SKILL.md` 都很短，详细规格按需从 `references/` 加载——避免一次性把所有上下文塞进模型。

### 维护约定（防臃肿）

1. **SKILL.md 只做路由与边界**：写「何时读哪个 reference」和与其他技能的边界，不复制 reference 内容；长度保持 ≤130 行。
2. **同一主题只留一处完整版**：其他位置写回链。出现两份近似内容即视为缺陷，先合并再新增（文种表、横向规则小节都因此收敛过）。
3. **优先并入现有小节，不新建文件**：只有职责确实不同才加 reference；references 超过 5 个时先重新分组。
4. **归档不进 references**：历史原文、旧版规格放 `archive/` 并在 SKILL.md 声明「不加载」；参考文献里不要留名字带 `SKILL` 的文件。
5. **CHANGELOG 只记版本变化**，不限行、不承载规则；规则变化进正文。
6. 新增前先问：能否并入现有小节？能删一句就先删。

## 设计取向

- **按影响面取深度**：单页小改不强制全量排查；横向、跨端、跨仓或反馈「多处说不清」时，才启用规则包、消费方矩阵与全量排查。
- **权威唯一**：同一规则值只在一处成文；阅读层只重述不新增；下游写摘要 + 回链，不复制平行全文。
- **未知不猜**：已确认规则、代码事实、技术待核验、历史记录、未来规划分开表述；未定项进待确认表，不写成已定。
- **状态不混淆**：规则完整性、实现一致性、验证结果、任务完成状态分别判断；跳过或未执行不算通过。
- **证据分级**：文档、源码、逻辑测试、构建、可见浏览器、自动化、CI、真实接口分别说明能证明什么。

## 版本

各技能独立版本，见各自的 `CHANGELOG.md`：

- `change-list-authoring` v1.2
- `prd-rule-authoring` v2.2
- `requirements-docs-viewer` v1.4

## License

[MIT](LICENSE)
