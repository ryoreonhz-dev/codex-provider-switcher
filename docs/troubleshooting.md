# Troubleshooting

## Quick Check

Run:

```bash
codex-toggle doctor
```

This checks:

- Active Codex config
- OpenAI baseline config
- DeepSeek baseline config
- Moon Bridge directory
- Moon Bridge config
- Moon Bridge process status
- DeepSeek API key presence
- Codex Desktop App name

## Verify Current Provider

```bash
codex-toggle status
```

Expected OpenAI mode:

```text
Current model path: OpenAI / GPT
Moon Bridge: stopped
```

Expected DeepSeek mode:

```text
Current model path: DeepSeek / Moon Bridge
Moon Bridge: running
model_provider = "moonbridge"
base_url = "http://127.0.0.1:38440/v1"
```

## Verify Actual DeepSeek Model

```bash
codex-toggle logs 80
```

Look for:

```text
actual_model=deepseek-v4-pro
```

or:

```text
actual_model=deepseek-v4-flash
```

## `connection refused`

Moon Bridge is not running or the configured port is wrong.

Run:

```bash
codex-toggle start
codex-toggle status
```

## Codex App Still Uses OpenAI

Run:

```bash
cat ~/.codex/config.toml
```

The active config should contain:

```toml
model_provider = "moonbridge"
base_url = "http://127.0.0.1:38440/v1"
wire_api = "responses"
```

Then restart the app:

```bash
codex-toggle restart-app
```

## Codex Desktop App Does Not Show DeepSeek Models

This can happen with custom providers. Use explicit script commands instead:

```bash
codex-toggle deepseek-pro
codex-toggle deepseek-flash
```

Then check `~/.codex/config.toml`:

```toml
model = "deepseek-v4-pro"
```

or:

```toml
model = "deepseek-v4-flash"
```

## DeepSeek Config Was Edited by App

If the current DeepSeek config works and you want to save it as the new baseline:

```bash
codex-toggle sync-deepseek
```

This copies `~/.codex/config.toml` to `~/.codex/config.deepseek.toml` after confirming the active config is DeepSeek / Moon Bridge.

## Moon Bridge Path Is Different

Override the default path:

```bash
export MOON_BRIDGE_DIR="/your/path/moon-bridge"
codex-toggle deepseek-flash
```

## Codex App Name Is Different

Override the default App name:

```bash
CODEX_APP_NAME="Codex" codex-toggle restart-app
```
