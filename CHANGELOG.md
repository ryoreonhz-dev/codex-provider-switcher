# Changelog

## 0.2.0

- Added configurable provider/model registry support through `~/.codex/codex-providers.yml`.
- Added built-in default registry for OpenAI and Moon Bridge / DeepSeek.
- Added `list`, `init-config`, `use`, `provider`, and generic `sync` commands.
- Kept existing `openai`, `deepseek`, `deepseek-pro`, `deepseek-flash`, and `sync-deepseek` commands as compatibility aliases.
- Added `examples/codex-providers.example.yml`.
- Added `yq` v4 diagnostics for custom registry parsing.

## 0.1.0

Initial public version.

- Added `codex-toggle` script.
- Added OpenAI / DeepSeek switching.
- Added DeepSeek Pro and Flash explicit switching.
- Added Moon Bridge start and stop automation.
- Added Codex Desktop App restart support.
- Added `status`, `doctor`, `logs`, and `sync-deepseek` commands.
- Added documentation for Codex Desktop custom model picker limitation.
- Added mobile remote Codex compatibility verification notes.
