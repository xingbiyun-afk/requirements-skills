# 安装说明

> **唯一源 = 本仓库**（`git clone` 到本机的位置）：三个技能的编辑与读取都以仓库为准。
> **软链**指向本仓库：`~/.codex/skills`、`~/.dsh/skills`、`~/.workbuddy/skills`、`~/.trae-cn/skills`、`~/.zcode/skills`；
> **实体副本**：Kimi 托管目录、DeepSeek Harness 工作区、桌面 skills（原因见 §3.2）。
> **规则**：所有 AI 工具只读仓库——软链根经软链读仓库，Kimi 等副本根以同步副本为准；任何工具不得直接改副本。

## 1. 克隆

```bash
git clone https://github.com/xingbiyun-afk/requirements-skills.git ~/Desktop/requirements-skills
```

下文假设仓库位于 `~/Desktop/requirements-skills`；其他位置需同步修改脚本里的 `REPO_ROOT` 行为（脚本已自动取自身所在目录，无需手改）。

## 2. 建立软链（Codex / DSH / WorkBuddy / Trae / ZCode）

```bash
REPO=~/Desktop/requirements-skills
for root in ~/.codex/skills ~/.dsh/skills ~/.workbuddy/skills ~/.trae-cn/skills ~/.zcode/skills; do
  mkdir -p "$root"
  for s in change-list-authoring prd-rule-authoring requirements-docs-viewer; do
    rm -rf "$root/$s"
    ln -s "$REPO/$s" "$root/$s"
  done
done
```

> 这五个工具都能跟随符号链接（Trae 与 WorkBuddy 的技能目录里本来就有指向 `~/.agents/skills` 的软链；ZCode 的 `~/.zcode/skills` 里也全是软链且正常加载）。

## 3. 同步实体副本根（含 Kimi）

### 3.1 各工具的读取来源（唯一源 = 本仓库）

| 工具 | 读取路径 | 方式 |
|---|---|---|
| Codex | `~/.codex/skills/<skill>` | 软链 → 仓库 |
| DSH | `~/.dsh/skills/<skill>` | 软链 → 仓库（DSH 侧已处理） |
| WorkBuddy | `~/.workbuddy/skills/<skill>` | 软链 → 仓库 |
| Trae | `~/.trae-cn/skills/<skill>` | 软链 → 仓库 |
| ZCode | `~/.zcode/skills/<skill>` | 软链 → 仓库 |
| Kimi（daimon 托管） | `~/Library/Application Support/kimi-desktop/daimon-share/daimon/skills/<skill>` | 实体副本（同步脚本维护） |
| DeepSeek Harness 工作区 | `~/Documents/deepseek-harness/default-workspace/skills/<skill>` | 实体副本（同步脚本维护） |
| 桌面 skills | `~/Desktop/代码文件仓库/skills/<skill>` | 实体副本（同步脚本维护） |

规则：**三个技能的唯一编辑源/读取源都是本仓库**。软链根的工具经软链读到仓库；Kimi 与实体副本根经同步副本读到仓库内容。任何工具不得把本地副本当作编辑源，也不得绕过仓库改副本。

### 3.2 Kimi 为什么必须实体副本（单独说明）

Kimi 的技能目录由 daimon 托管，**daimon 会把技能目录实体化：软链放进去会被还原成普通目录**，所以 Kimi 不能靠软链指向仓库，只能放真实文件副本。

因此 Kimi 侧是单向流动：

1. 只在本仓库编辑、提交、推送；
2. 运行 `./sync-skills-to-all-roots.sh`，脚本用 `cp -aL` 把仓库内容复制到 Kimi 托管目录（替换前自动备份旧副本到 `~/Documents/skill-backups/<时间戳>/`）；
3. Kimi 新会话/重启后加载新内容。

红线：

- **不要直接编辑 Kimi 托管副本**——下次同步会被仓库内容覆盖，且副本与仓库漂移后 `--check` 会报「不同」；
- 发现 Kimi 副本与仓库不一致时，不要手工改副本，回到仓库核对后跑同步脚本；
- 其他 AI 工具同理：三个技能只读仓库（软链根跟随软链，Kimi 等副本根以同步副本为准），不各自维护版本。

### 3.3 同步命令

```bash
./sync-skills-to-all-roots.sh --check   # 只核对哈希与软链
./sync-skills-to-all-roots.sh           # 备份旧副本，同步并核对
```

## 4. 验证

```bash
readlink ~/.codex/skills/prd-rule-authoring ~/.dsh/skills/prd-rule-authoring ~/.zcode/skills/prd-rule-authoring
./sync-skills-to-all-roots.sh --check
head -8 ~/.codex/skills/prd-rule-authoring/SKILL.md
```

- 用「写一份横向规则定位/多消费方说明」和「检查一个查看器搜索上下文场景」做最小回归。

## 5. 回滚

```bash
# 从备份目录恢复对应技能，再按第 2 步重建软链
cp -a ~/Documents/skill-backups/<STAMP>/<skill> ~/.codex/skills/<skill>
```

## 6. 注意

- **只在本仓库编辑**，不要直接改 Codex/DSH/Kimi 副本，避免多份漂移；
- 改完提交并推送后，跑一次 `./sync-skills-to-all-roots.sh` 让副本跟上；
- **不要把备份目录放进任何技能根目录**：发现器会把 `<dir>/SKILL.md` 当成正式技能，与正式版同名时会抢过正式版；
- 三个技能互相解耦，可分别安装。
