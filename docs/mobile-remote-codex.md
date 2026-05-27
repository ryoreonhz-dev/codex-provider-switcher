# Mobile Remote Codex Compatibility

ChatGPT mobile app can operate Codex running on a connected Mac host. In this setup, the mobile app is the control surface and the Mac Codex host performs the actual work.

When the Mac host is switched to DeepSeek / Moon Bridge, mobile-triggered tasks are expected to follow the same local provider configuration:

```text
ChatGPT mobile app
  -> Mac Codex App / Codex host
  -> ~/.codex/config.toml
  -> Moon Bridge
  -> DeepSeek API
```

This should be treated as a compatibility scenario to verify because custom provider behavior may vary by Codex Desktop App version.

## Verification SOP

Switch the Mac host to DeepSeek Flash:

```bash
codex-toggle deepseek-flash
```

Check status:

```bash
codex-toggle status
```

Use ChatGPT mobile app to trigger a small Codex task on the Mac host.

Then inspect Moon Bridge logs:

```bash
codex-toggle logs 50
```

Success signal:

```text
actual_model=deepseek-v4-flash
```

For Pro:

```bash
codex-toggle deepseek-pro
codex-toggle logs 50
```

Success signal:

```text
actual_model=deepseek-v4-pro
```

## Limitations

- The Mac host must be online, awake, signed in, and running Codex.
- Moon Bridge must be running for DeepSeek mode.
- File operations and approvals still depend on the Mac-side Codex sandbox and approval policy.
- Computer Use / GUI tasks require additional validation because they rely on tool calling, screenshots, and action planning.
