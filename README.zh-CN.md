# codex-provider-switcher

简体中文 | [English](README.md)

> Codex Desktop App / Codex CLI 的 OpenAI 与第三方 Provider / Model 一键切换工具，内置默认支持 Moon Bridge / DeepSeek。

`codex-provider-switcher` 是一个本地运维脚本项目，用于在 OpenAI 官方模型和可配置的第三方模型通道之间快速切换。默认情况下，它仍然支持基于 Moon Bridge 的 DeepSeek 通道。

它适合这样的使用场景：

- 平时使用 OpenAI / GPT 作为 Codex 主模型通道
- 当 Codex 额度、成本或可用性受限时，临时切换到 DeepSeek 或其他第三方模型
- 使用 Codex Desktop App 为主，同时希望保留 Codex CLI 兼容性
- 希望通过一个命令完成配置切换、Moon Bridge 启停、Codex App 重启和状态检查

> 本项目不是 OpenAI 官方项目，也不是 DeepSeek / Moon Bridge 官方项目。它只负责切换本地 Codex 配置文件，并管理本地辅助进程，例如 Moon Bridge。

## 背景

Codex 支持通过 `~/.codex/config.toml` 配置自定义 model provider。  
通过 Moon Bridge，可以将 Codex 的请求转发到 DeepSeek API；通过 `~/.codex/codex-providers.yml`，也可以继续注册更多 provider / model。

典型链路如下：

```text
Codex Desktop App / Codex CLI
  -> ~/.codex/config.toml
  -> Moon Bridge
  -> DeepSeek API
```

手动切换配置时，通常需要反复编辑 `config.toml`、启动或关闭 Moon Bridge、重启 Codex App，并检查日志确认实际模型是否正确。这个过程容易出错。

`codex-toggle` 的目标就是把这些操作固化成一个命令，并允许后续通过本地 YAML 扩展更多第三方模型。

## 功能

- 在 OpenAI / GPT 与第三方 provider/model 之间切换
- 没有自定义 YAML 时，内置 DeepSeek / Moon Bridge 默认配置
- 支持 DeepSeek Pro / Flash 显式切换
- 支持通过 `~/.codex/codex-providers.yml` 注册更多 provider / model
- 自动启动 Moon Bridge
- 自动关闭 Moon Bridge
- 自动重启 Codex Desktop App
- 查看当前模型 provider 状态
- 查看 Moon Bridge 日志
- 执行本地环境体检
- 将当前可用 provider 配置同步回基线配置文件

## 前置条件

你需要已经完成以下准备：

- macOS
- Codex Desktop App
- Codex CLI
- Go
- yq v4（使用自定义 provider registry 时需要）
- Moon Bridge
- DeepSeek API Key
- 已经生成可用的 Codex 配置文件

默认路径假设如下：

```text
~/.codex/config.toml
~/.codex/config.openai.toml
~/.codex/config.deepseek.toml
~/.codex/codex-providers.yml
~/Documents/ai_tools/moon-bridge/config.yml
```

如果你的目录不同，需要修改 `scripts/codex-toggle` 中对应变量。

如果要使用自定义 provider registry，需要安装 `yq`：

```bash
brew install yq
```

## 安装

克隆仓库：

```bash
git clone https://github.com/ryoreonhz-dev/codex-provider-switcher.git
cd codex-provider-switcher
```

安装脚本：

```bash
mkdir -p ~/.local/bin
cp scripts/codex-toggle ~/.local/bin/codex-toggle
chmod +x ~/.local/bin/codex-toggle
```

确保 `~/.local/bin` 已加入 PATH：

```bash
grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

验证：

```bash
which codex-toggle
codex-toggle status
```

## 配置文件约定

脚本默认使用这些 Codex 配置文件：

```text
~/.codex/config.toml
~/.codex/config.openai.toml
~/.codex/config.deepseek.toml
~/.codex/codex-providers.yml
```

含义如下：

| 文件 | 说明 |
|---|---|
| `config.toml` | Codex 当前实际生效配置 |
| `config.openai.toml` | OpenAI / GPT 配置基线 |
| `config.deepseek.toml` | DeepSeek / Moon Bridge 配置基线 |
| `codex-providers.yml` | 可选的 provider / model 注册表 |

切换时，脚本会把对应 provider 的基线文件复制到 `config.toml`，必要时再修改顶层 `model` 字段。

如果 `codex-providers.yml` 不存在，脚本会使用内置默认注册表，旧命令仍然可用。创建可编辑注册表：

```bash
codex-toggle init-config
```

也可以参考：

```text
examples/codex-providers.example.yml
```

## 命令说明

查看当前状态：

```bash
codex-toggle status
```

自动反向切换：

```bash
codex-toggle
```

如果当前是 OpenAI / GPT，会切到 DeepSeek / Moon Bridge。  
如果当前是 DeepSeek / Moon Bridge，会切回 OpenAI / GPT。

强制切回 OpenAI：

```bash
codex-toggle openai
```

切到 Moon Bridge 默认模型：

```bash
codex-toggle deepseek
```

切到 DeepSeek Pro：

```bash
codex-toggle deepseek-pro
```

切到 DeepSeek Flash：

```bash
codex-toggle deepseek-flash
```

只启动 Moon Bridge：

```bash
codex-toggle start
```

只关闭 Moon Bridge：

```bash
codex-toggle stop
```

重启 Codex App：

```bash
codex-toggle restart-app
```

环境体检：

```bash
codex-toggle doctor
```

列出 provider / model：

```bash
codex-toggle list
```

按模型或 alias 切换：

```bash
codex-toggle use deepseek-pro
codex-toggle use deepseek-v4-flash
```

只切换 provider 基线配置：

```bash
codex-toggle provider openai
codex-toggle provider moonbridge
```

查看 Moon Bridge 日志：

```bash
codex-toggle logs 50
```

同步当前 DeepSeek 配置：

```bash
codex-toggle sync-deepseek
```

通用同步命令：

```bash
codex-toggle sync moonbridge
```

## 推荐使用方式

日常使用 OpenAI / GPT：

```bash
codex-toggle openai
```

备用模型优先使用 DeepSeek Flash：

```bash
codex-toggle deepseek-flash
```

复杂代码分析、长上下文任务或重构任务使用 DeepSeek Pro：

```bash
codex-toggle deepseek-pro
```

切换后检查状态：

```bash
codex-toggle status
```

查看实际路由模型：

```bash
codex-toggle logs 50
```

重点看日志中的：

```text
actual_model=deepseek-v4-pro
```

或：

```text
actual_model=deepseek-v4-flash
```

## Codex Desktop App 的模型菜单限制

当前 Codex Desktop App 对自定义 provider 的模型选择器支持并不稳定。

实际观察到的现象包括：

- App 可以识别 `Moon Bridge` provider
- `models_catalog.json` 中存在 `deepseek-v4-pro` 和 `deepseek-v4-flash`
- Moon Bridge `/v1/models` 能返回 DeepSeek 模型列表
- 但 Codex Desktop App 的模型菜单不一定展示这些第三方模型
- 某些情况下，右侧“模型”输入框也无法手动输入模型名

因此，本项目采用更稳定的方式：  
通过脚本直接修改 `~/.codex/config.toml` 中的 `model` 字段。

例如：

```toml
model = "deepseek-v4-pro"
model_provider = "moonbridge"
```

或：

```toml
model = "deepseek-v4-flash"
model_provider = "moonbridge"
```

## 移动端远程控制 Codex

如果你使用 ChatGPT 手机端远程操作电脑端 Codex，需要注意：

手机端只是远程控制入口，实际任务仍在电脑端 Codex host 上执行。

因此，当电脑端 Codex 已经通过 `codex-toggle` 切换到 DeepSeek / Moon Bridge 时，手机端远程触发的任务理论上也会沿用电脑端当前配置。

建议验证方式：

```bash
codex-toggle deepseek-flash
codex-toggle status
```

然后在手机端发起一个低风险任务，例如创建测试文件。  
再在 Mac 上查看日志：

```bash
codex-toggle logs 50
```

如果看到：

```text
actual_model=deepseek-v4-flash
```

说明手机端远程触发的任务已经走 DeepSeek。

该场景建议先验证后使用，不建议未经测试直接用于关键生产任务。

## 故障排查

### 1. Codex App 没有走 DeepSeek

检查：

```bash
codex-toggle status
```

确认当前状态是：

```text
Current model path: DeepSeek / Moon Bridge
```

并确认配置里有：

```toml
model_provider = "moonbridge"
base_url = "http://127.0.0.1:38440/v1"
wire_api = "responses"
```

### 2. Moon Bridge 没启动

执行：

```bash
codex-toggle start
```

或：

```bash
codex-toggle doctor
```

### 3. 不确定实际模型

查看日志：

```bash
codex-toggle logs 80
```

重点看：

```text
actual_model=deepseek-v4-pro
actual_model=deepseek-v4-flash
```

### 4. DeepSeek 配置被 App 改写

如果你确认当前 DeepSeek 配置可用，可以同步回基线：

```bash
codex-toggle sync-deepseek
```

### 5. 想恢复 OpenAI 官方模型

```bash
codex-toggle openai
```

## 安全说明

- 不要把 DeepSeek API Key 提交到 GitHub
- `examples/moonbridge.config.example.yml` 只应放示例 Key
- 本项目不会上传你的 Codex 配置
- 本项目不会代理任何远程服务
- 所有切换操作都发生在本地文件系统

## 免责声明

本项目不是 OpenAI 官方项目，也不是 DeepSeek 官方项目。  
Codex Desktop App、Codex CLI、Moon Bridge 和 DeepSeek API 的行为可能随版本变化。

本项目仅作为本地运维辅助工具使用。请在理解配置影响后再用于生产工作流。

## License

MIT
