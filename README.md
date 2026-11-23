# codex-init

codex-init 用于初始化和更新 Codex 开发环境，统一配置团队开发工具与全局 `AGENTS.md` 规则。

## 安装或更新

把这段话发给 Codex。

```text
请按这个仓库的 INSTALL.md 安装或增量更新 codex-init。
https://github.com/Today-Weekly-Release-Company/codex-init
```

已有安装可直接复用。详见 [增量更新步骤](INSTALL.md#更新已有安装)。

## 可选：无人值守安装

macOS、Linux、WSL 可运行：

```bash
git clone https://github.com/Today-Weekly-Release-Company/codex-init.git
cd codex-init
./install.sh
```

Windows 原生 PowerShell 使用对应入口：

```powershell
git clone https://github.com/Today-Weekly-Release-Company/codex-init.git
Set-Location codex-init
.\install.ps1
```

PowerShell 脚本受系统执行策略管理；遇到限制时按 [INSTALL.md](INSTALL.md) 处理。Windows 原生与 WSL 各自拥有独立的 Codex 主目录，安装时以 Codex 实际运行环境为准。

遇到依赖缺失或配置冲突时，使用上面的文本指令交给 Codex 处理。

## 安装内容

- 同步全局 Codex `AGENTS.md` 托管规则；
- 安装并配置 Rust Token Killer（RTK）；
- 验证命令与全局配置状态。

## 可选：在 Paimon 项目中接入 Code Inspector

Code Inspector 可以从开发页面上的元素直接跳到编辑器中的对应源码。使用 Webpack 的 Paimon 项目可按 [Code Inspector 接入步骤](INSTALL.md#6-可选接入-code-inspector) 安装项目依赖并配置 `paimon.config.js`。插件默认仅在开发环境生效。 [官方文档](https://inspector.fe-dev.cn/guide/start.html) · [GitHub 源码仓库](https://github.com/zh-lx/code-inspector)

启动开发服务后，macOS 按住 `Option + Shift`，Windows 按住 `Alt + Shift`。移动鼠标选中元素，看到遮罩后点击左键，编辑器会打开对应文件并定位到源码行。

![Code Inspector 官方演示：从网页元素跳转到编辑器中的源码](https://cdn.jsdelivr.net/gh/zh-lx/static-img/code-inspector/demo.gif)

浏览器控制台也会显示组合键提示。 [官方快速开始](https://inspector.fe-dev.cn/guide/start.html#使用)

![Code Inspector 官方截图：浏览器控制台中的组合键提示](https://cdn.jsdelivr.net/gh/zh-lx/static-img/code-inspector/console-success.png)

## 仓库结构

```text
.
├── README.md
├── INSTALL.md
├── install.sh
├── install.ps1
├── templates/
│   └── AGENTS.md
├── scripts/
│   ├── sync-agents.sh
│   ├── sync-agents.ps1
│   ├── verify.sh
│   └── verify.ps1
├── tests/
│   ├── scripts_test.sh
│   └── scripts_test.ps1
└── .agents/
    └── skills/
        └── playwright-cli/
```

仓库级共享技能仅保留 `.agents/skills/playwright-cli/`，在 Codex 中打开本仓库后即可使用。
