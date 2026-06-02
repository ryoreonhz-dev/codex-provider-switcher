# Codex Provider Switch Operations Baseline v1.3

## Purpose

This baseline defines a local operations workflow for switching Codex Desktop App / Codex CLI between OpenAI and configurable third-party providers/models. The built-in default path supports DeepSeek through Moon Bridge.

## Standard Files

```text
~/.codex/config.toml
~/.codex/config.openai.toml
~/.codex/config.deepseek.toml
~/.codex/config.previous.toml
~/.codex/codex-providers.yml
~/.codex/models_catalog.json
~/.codex/logs/moonbridge.log
~/.codex/moonbridge.pid
~/.local/bin/codex-toggle
```

## Provider Modes

OpenAI mode:

```text
Codex -> OpenAI official provider
```

DeepSeek mode:

```text
Codex -> Moon Bridge -> DeepSeek API
```

Custom registry mode:

```text
Codex -> ~/.codex/codex-providers.yml -> provider baseline config -> optional local service
```

## Command Baseline

```bash
codex-toggle status
codex-toggle doctor
codex-toggle list
codex-toggle init-config
codex-toggle use <model-or-alias>
codex-toggle provider <provider>
codex-toggle openai
codex-toggle deepseek
codex-toggle deepseek-pro
codex-toggle deepseek-flash
codex-toggle logs 50
codex-toggle sync-deepseek
codex-toggle sync <provider>
codex-toggle start
codex-toggle start moonbridge
codex-toggle stop
codex-toggle stop moonbridge
codex-toggle restart-app
```

## Daily SOP

Use OpenAI by default:

```bash
codex-toggle openai
```

Use DeepSeek Flash as low-cost fallback:

```bash
codex-toggle deepseek-flash
codex-toggle use deepseek-flash
```

Use DeepSeek Pro for heavier tasks:

```bash
codex-toggle deepseek-pro
codex-toggle use deepseek-v4-pro
```

Verify status:

```bash
codex-toggle status
```

List configured providers and models:

```bash
codex-toggle list
```

Verify actual routing:

```bash
codex-toggle logs 50
```

Expected log signal:

```text
actual_model=deepseek-v4-pro
actual_model=deepseek-v4-flash
```

## Codex Desktop Model Picker Limitation

Codex Desktop App may recognize the Moon Bridge provider but not display all third-party models from `models_catalog.json` in the model picker.

Operational workaround:

- Use `codex-toggle deepseek-pro` to set `model = "deepseek-v4-pro"`.
- Use `codex-toggle deepseek-flash` to set `model = "deepseek-v4-flash"`.
- Verify actual model from Moon Bridge logs.

## Config Sync Rule

When the current DeepSeek active config has been verified and should become the new baseline:

```bash
codex-toggle sync-deepseek
codex-toggle sync moonbridge
```

This updates:

```text
~/.codex/config.deepseek.toml
```

## Mobile Remote Codex Compatibility

ChatGPT mobile app can operate a connected Mac Codex host. When the Mac host is currently switched to DeepSeek / Moon Bridge, mobile-triggered tasks are expected to use the Mac-side active provider config.

Verification:

```bash
codex-toggle deepseek-flash
codex-toggle logs 50
```

Then trigger a low-risk task from mobile and confirm:

```text
actual_model=deepseek-v4-flash
```

This is a compatibility scenario and should be verified before relying on it for production work.

## Fault Handling

Run doctor first:

```bash
codex-toggle doctor
```

Check logs:

```bash
codex-toggle logs 80
```

Restart App:

```bash
codex-toggle restart-app
```

Restart Moon Bridge:

```bash
codex-toggle stop
codex-toggle start
```

## Change Record

### v1.3

- Added provider/model registry support through `~/.codex/codex-providers.yml`.
- Added `list`, `init-config`, `use`, `provider`, and generic `sync` commands.
- Kept DeepSeek Pro / Flash and `sync-deepseek` compatibility commands.
- Added `yq` v4 requirement for custom registry parsing.

### v1.2

- Added mobile remote Codex compatibility notes.
- Added verification SOP for mobile-triggered DeepSeek routing.

### v1.1

- Added `doctor`, `logs`, and `sync-deepseek`.
- Added explicit DeepSeek Pro / Flash switching.
- Added Codex Desktop model picker limitation workaround.

### v1.0

- Initial OpenAI / DeepSeek provider switching workflow.
