# Changelog

## 0.2.1

- Escaped model replacement so model names containing `/`, `\`, or `&` can be written safely.
- Added generic `sync <provider>` safety checks to prevent overwriting a provider baseline with an unrelated active config.
- Added stricter mikefarah/yq v4 detection for custom provider registries.
- Added nested path creation for `codex-toggle init-config` when `CODEX_PROVIDER_CONFIG` points to a custom location.
- Added shell smoke tests and GitHub Actions coverage.

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
