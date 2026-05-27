# codex-provider-switcher

简体中文 | [English](README.md)

> Codex Desktop App / Codex CLI 的 OpenAI 与 Moon Bridge / DeepSeek Provider 一键切换工具。

`codex-provider-switcher` 是一个本地运维脚本，用于在 Codex Desktop App / Codex CLI 中快速切换 OpenAI 官方模型与基于 Moon Bridge 的 DeepSeek 第三方模型 Provider。

它适合把 OpenAI / GPT 作为主通道，把 DeepSeek 作为备用通道的用户。

## 这是什么

这个项目提供一个 `codex-toggle` 脚本，用于管理：

- Codex 当前使用的 `~/.codex/config.toml`
- OpenAI 与 DeepSeek 配置文件切换
- Moon Bridge 本地服务启停
- Codex Desktop App 自动重启
- DeepSeek Pro / Flash 模型切换
- 状态检查、日志查看和配置固化

典型链路：

```text
Codex Desktop App / Codex CLI
  -> ~/.codex/config.toml
  -> Moon Bridge
  -> DeepSeek API
