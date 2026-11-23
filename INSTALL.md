# codex-init 安装执行手册

本文档供 Codex 或其他具备终端能力的 AI Agent 执行。根据用户当前环境安装或增量更新套件，并保留已有配置。

支持 macOS、Linux、Windows 原生 PowerShell 和 WSL。先判断 Codex 的实际运行环境：Windows 原生使用 `.ps1`；WSL 使用 `.sh`。两者默认的 Codex 主目录分别是 `%USERPROFILE%\.codex` 和 WSL 用户目录下的 `~/.codex`，应配置与目标 Codex 会话相同的环境。

## 目标状态

完成后应满足：

1. 全局 Codex `AGENTS.md` 包含本仓库维护的规则区块；
2. Rust Token Killer 可执行，`rtk gain` 返回正常；
3. 用户已有的 `AGENTS.md`、MCP 和 Shell 配置保持有效。

## 执行原则

- 先检查，再安装；已经可用的工具直接复用。
- 使用工具官方安装命令和配置入口，优先沿用当前环境的版本管理器。
- 全局文件只修改明确声明的托管区块。
- 涉及覆盖冲突、移除同名工具、修改 Shell 启动文件或授权时，先向用户说明具体影响并取得确认。
- 每一步完成后立即验证，失败时保留错误信息并停止相关后续步骤。

## 更新已有安装

先获取本仓库最新版本，再根据新版手册检查本地状态。复用已可用的 Codex、RTK 和现有配置，只补齐适用于当前环境的新组件，或同步有变化的托管配置。Codex 和 RTK 本身的版本升级单独处理。

已有克隆位于干净的 `main`、没有独立的本地提交，且 `origin` 指向本仓库时，在仓库根目录执行以下命令，适用于 macOS 和 Windows。

```bash
git pull --ff-only origin main
```

其他情况或无法快进时，按 [准备仓库](#1-准备仓库) 使用新的临时克隆。更新后重新阅读 `INSTALL.md`，执行本次需要的步骤。

如果只更新全局规则，运行对应平台的 [规则同步](#3-同步全局-agentsmd) 和 [验证](#5-验证) 脚本。同步脚本只应用本仓库的托管区块，输出 `UPDATED` 或 `UNCHANGED`。同步有变化时，新建 Codex 会话以加载更新后的规则。 [Codex 规则加载说明](https://developers.openai.com/codex/guides/agents-md)

## 1. 准备仓库

首次安装时可使用现有的官方克隆。更新已有安装时，按上一节获取最新版本。需要临时克隆时，先创建临时目录，再执行以下命令。

```bash
git clone --depth 1 https://github.com/Today-Weekly-Release-Company/codex-init.git
cd codex-init
```

安装或更新完成后清理本次创建的临时克隆目录。用户主动选择的长期目录予以保留。

## 2. 检查当前环境

收集以下信息并据此决定安装路径：

macOS、Linux、WSL：

```bash
uname -s
uname -m
printf '%s\n' "$SHELL"
command -v rtk && rtk --version
command -v rtk && rtk gain
```

Windows 原生 PowerShell：

```powershell
$PSVersionTable.PSVersion
Get-Command rtk -ErrorAction SilentlyContinue
rtk gain
```

单个命令缺失时记录结果并继续检查其余项目；检查 Windows 当前的 PowerShell 执行策略和可用的 `winget`。

同时检查：

- Codex 主目录中的 `AGENTS.md`、`AGENTS.override.md` 和 `config.toml`；
- `CODEX_HOME` 环境变量；
- 当前 Shell 的 PATH 配置。发现同一工具有多份安装时，记录当前实际使用的安装路径和版本。

向用户简短说明即将新增或更新的内容，再进入写操作。

## 3. 同步全局 AGENTS.md

执行仓库提供的原子脚本：

```bash
./scripts/sync-agents.sh
```

Windows 原生 PowerShell：

```powershell
.\scripts\sync-agents.ps1
```

为兼容已有安装，脚本沿用以下托管标记：

```text
<!-- AI_DEV_KIT_START -->
<!-- AI_DEV_KIT_END -->
```

脚本会保留标记外内容，并在发生变更前生成 `AGENTS.md.ai-dev-kit.bak`。遇到单边缺失、重复或顺序错误的标记时，先检查文件并征求用户处理意见。若存在非空的 `AGENTS.override.md`，Codex 将优先读取它；需先和用户确定全局规则的生效方式。

## 4. 安装 RTK

先运行 `rtk gain` 判断现有 `rtk` 是否为 Rust Token Killer。

- `rtk gain` 成功：保留当前安装；
- 找不到 `rtk`：使用官方安装器；
- `rtk` 存在且 `rtk gain` 失败：说明存在同名工具冲突，取得用户确认后再处理。

macOS/Linux 官方安装命令：

```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```

Windows 原生 PowerShell 使用官方 winget 包：

```powershell
winget install --id rtk-ai.rtk --exact
```

安装后如当前终端尚未识别 `rtk`，重新打开 PowerShell 再继续。WSL 沿用 Linux 安装命令。

确认 `rtk` 所在目录已经进入 PATH。可用 `rtk init --global --codex --show` 查看全局集成状态。已有可用的集成直接复用，需要新增或修复集成时运行以下命令。

```bash
rtk init --global --codex
```

运行 `rtk --version` 和 `rtk gain`，确认当前工具可用并记录版本。

PATH 缺失时，根据当前 Shell 配置方式选择修复方法，展示变更并取得用户确认。Windows 优先由 winget 管理 PATH。

## 5. 验证

执行只读验证脚本：

```bash
./scripts/verify.sh
```

Windows 原生 PowerShell：

```powershell
.\scripts\verify.ps1
```

如果 Windows 执行策略阻止仓库中的 `.ps1` 文件运行，先检查组织策略。个人设备可在用户确认后参考 [Microsoft 执行策略说明](https://learn.microsoft.com/powershell/module/microsoft.powershell.security/set-executionpolicy)选择合适的作用范围；保持限制时，由 AI 按本节逐项执行只读验证命令。

所有项目均显示 `PASS` 后，提醒用户重启 Codex 或新建会话。

## 6. 可选接入 Code Inspector

用户提供使用 Webpack 的 Paimon 项目时，在该项目根目录接入 `code-inspector-plugin`。当前没有目标项目时，跳过这一步。 [官方文档](https://inspector.fe-dev.cn/guide/start.html) · [GitHub 源码仓库](https://github.com/zh-lx/code-inspector)

1. 检查 `package.json` 和 `paimon.config.js`，复用已有依赖和插件配置。使用 npm 的项目按当前平台执行以下命令。使用其他包管理器的项目沿用现有工具和锁文件。

   macOS、Linux、WSL：

   ```bash
   npm install -D code-inspector-plugin
   ```

   Windows 原生 PowerShell：

   ```powershell
   npm.cmd install -D code-inspector-plugin
   ```

2. 在 `paimon.config.js` 顶部引入插件。

   ```js
   const { codeInspectorPlugin } = require('code-inspector-plugin');
   ```

   将下面的配置合并到现有 `builder()` 的返回对象。已有 `webpack.plugins` 时，将插件追加到该数组并保留原有插件和其他 Webpack 配置。

   ```js
   webpack: {
     plugins: [codeInspectorPlugin({ bundler: 'webpack' })],
   },
   ```

3. 运行 `npm start`（Windows 原生 PowerShell 可运行 `npm.cmd start`）。打开开发页面，macOS 按住 `Option + Shift`，Windows 按住 `Alt + Shift`，移动鼠标直到目标元素出现遮罩，再点击左键验证编辑器能定位到源码。若组合键与系统快捷键冲突，可给插件加上 `showSwitch: true`，通过页面上的开关启用定位模式。编辑器识别失败时，按官方 IDE 指南在项目的 `.env.local` 中指定 `CODE_EDITOR`。 [插件配置](https://inspector.fe-dev.cn/api/basic.html) · [IDE 配置](https://inspector.fe-dev.cn/guide/ide.html)

插件默认识别 Webpack 的构建环境，仅在开发环境生效。使用自定义构建模式时，按项目的开发环境条件设置 `dev`。 [开发环境配置](https://inspector.fe-dev.cn/api/basic.html#dev)

## 7. 结果报告

向用户报告：

- RTK 的实际版本；
- 已复用、新增或更新的组件和配置，以及实际验证结果；
- 全局 `AGENTS.md` 的位置和备份位置（有备份时）；
- Code Inspector 的接入项目和点击定位验证结果（执行了可选步骤时）；
- 发生过的冲突、用户确认和保留事项；
- 需要用户执行的最后动作，例如重启 Codex。

## 无人值守路径

仓库根目录提供 `install.sh`（macOS/Linux/WSL）和 `install.ps1`（Windows 原生）。两者只覆盖标准环境；发现版本、PATH 或同名工具冲突时，回到本文档的 AI 执行流程。
