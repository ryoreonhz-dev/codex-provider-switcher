#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/codex-toggle"
TMP_DIR="$(mktemp -d)"
SYSTEM_PATH="/bin:/usr/bin:/usr/sbin:/sbin"

trap 'rm -rf "$TMP_DIR"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"

  [[ "$haystack" == *"$needle"* ]] || fail "expected output to contain: $needle"
}

assert_file_contains() {
  local file="$1"
  local needle="$2"

  grep -Fq "$needle" "$file" || fail "expected $file to contain: $needle"
}

make_base_mocks() {
  local bin_dir="$1"

  mkdir -p "$bin_dir"

  cat > "$bin_dir/curl" <<'EOF'
#!/usr/bin/env bash
if [[ "${MOCK_CURL_MODE:-running}" == "running" ]]; then
  printf '{"data":[]}'
  exit 0
fi
exit 7
EOF

  cat > "$bin_dir/pgrep" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF

  cat > "$bin_dir/pkill" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

  cat > "$bin_dir/osascript" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF

  cat > "$bin_dir/open" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

  chmod +x "$bin_dir/curl" "$bin_dir/pgrep" "$bin_dir/pkill" "$bin_dir/osascript" "$bin_dir/open"
}

make_yq_v4_mock() {
  local bin_dir="$1"

  make_base_mocks "$bin_dir"

  cat > "$bin_dir/yq" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then
  echo "yq (https://github.com/mikefarah/yq/) version v4.44.3"
  exit 0
fi

if [[ "${1:-}" == "e" ]]; then
  exit 0
fi

if [[ -n "${TARGET:-}" ]]; then
  case "$TARGET" in
    claude-sonnet|slash-alias) echo "claude-sonnet" ;;
  esac
  exit 0
fi

if [[ -n "${PROVIDER:-}" && -n "${FIELD:-}" ]]; then
  case "$PROVIDER:$FIELD" in
    claude:label) echo "Claude" ;;
    claude:config) echo "config.claude.toml" ;;
    claude:codex_provider) echo "anthropic" ;;
    claude:service) echo "" ;;
  esac
  exit 0
fi

if [[ -n "${MODEL_KEY:-}" && -n "${FIELD:-}" ]]; then
  case "$MODEL_KEY:$FIELD" in
    claude-sonnet:label) echo "Claude Sonnet" ;;
    claude-sonnet:provider) echo "claude" ;;
    claude-sonnet:model) echo "anthropic/claude&sonnet" ;;
    claude-sonnet:aliases) echo "slash-alias" ;;
  esac
  exit 0
fi

if [[ -n "${CODEX_PROVIDER:-}" ]]; then
  case "$CODEX_PROVIDER" in
    anthropic) echo "claude" ;;
  esac
  exit 0
fi

if [[ -n "${MODEL:-}" ]]; then
  case "$MODEL" in
    anthropic/claude\&sonnet) echo "claude-sonnet" ;;
  esac
  exit 0
fi

exit 0
EOF

  chmod +x "$bin_dir/yq"
}

make_wrong_yq_mock() {
  local bin_dir="$1"

  make_base_mocks "$bin_dir"

  cat > "$bin_dir/yq" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then
  echo "yq 3.4.1"
  exit 0
fi
exit 0
EOF

  chmod +x "$bin_dir/yq"
}

new_codex_home() {
  local name="$1"
  local home="$TMP_DIR/$name"

  mkdir -p "$home/logs"

  cat > "$home/config.toml" <<'EOF'
model = "gpt-5"
EOF

  cat > "$home/config.openai.toml" <<'EOF'
model = "gpt-5"
EOF

  cat > "$home/config.deepseek.toml" <<'EOF'
model = "moonbridge"
model_provider = "moonbridge"

[model_providers.moonbridge]
base_url = "http://127.0.0.1:38440/v1"
wire_api = "responses"
EOF

  printf '%s\n' "$home"
}

run_codex_with_path() {
  local home="$1"
  local path_prefix="$2"
  shift 2

  CODEX_HOME="$home" \
    CODEX_TOGGLE_SKIP_APP_RESTART=1 \
    PATH="$path_prefix:$SYSTEM_PATH" \
    "$SCRIPT" "$@"
}

run_codex() {
  run_codex_with_path "$1" "$BASE_MOCK_BIN" "${@:2}"
}

BASE_MOCK_BIN="$TMP_DIR/mock-bin"
YQ_MOCK_BIN="$TMP_DIR/yq-mock-bin"
WRONG_YQ_MOCK_BIN="$TMP_DIR/wrong-yq-mock-bin"
make_base_mocks "$BASE_MOCK_BIN"
make_yq_v4_mock "$YQ_MOCK_BIN"
make_wrong_yq_mock "$WRONG_YQ_MOCK_BIN"

home="$(new_codex_home built-in-list)"
output="$(run_codex "$home" list)"
assert_contains "$output" "deepseek-v4-pro"
assert_contains "$output" "aliases=deepseek-flash"

home="$(new_codex_home provider-openai)"
cp "$home/config.deepseek.toml" "$home/config.toml"
run_codex "$home" provider openai >/dev/null
assert_file_contains "$home/config.toml" 'model = "gpt-5"'

home="$(new_codex_home deepseek-flash)"
run_codex "$home" deepseek-flash >/dev/null
assert_file_contains "$home/config.toml" 'model = "deepseek-v4-flash"'

home="$(new_codex_home missing-provider-config)"
before="$(cat "$home/config.toml")"
rm "$home/config.deepseek.toml"
if run_codex "$home" deepseek-pro >/dev/null 2>&1; then
  fail "deepseek-pro should fail when provider config is missing"
fi
after="$(cat "$home/config.toml")"
[[ "$before" == "$after" ]] || fail "active config changed after missing provider config failure"

home="$(new_codex_home nested-init)"
CODEX_PROVIDER_CONFIG="$home/nested/registry/codex-providers.yml" run_codex "$home" init-config >/dev/null
[[ -f "$home/nested/registry/codex-providers.yml" ]] || fail "init-config did not create nested registry path"

home="$(new_codex_home custom-model)"
cat > "$home/codex-providers.yml" <<'EOF'
providers:
  claude:
    label: "Claude"
    config: "config.claude.toml"
    codex_provider: "anthropic"
    service: ""
models:
  claude-sonnet:
    label: "Claude Sonnet"
    provider: "claude"
    model: "anthropic/claude&sonnet"
    aliases: ["slash-alias"]
EOF
cat > "$home/config.claude.toml" <<'EOF'
model = "placeholder"
model_provider = "anthropic"
EOF
run_codex_with_path "$home" "$YQ_MOCK_BIN" use slash-alias >/dev/null
assert_file_contains "$home/config.toml" 'model = "anthropic/claude&sonnet"'
assert_file_contains "$home/config.toml" 'model_provider = "anthropic"'
output="$(run_codex_with_path "$home" "$YQ_MOCK_BIN" status)"
assert_contains "$output" "Current provider: Claude"
assert_contains "$output" "Registry model: Claude Sonnet (claude-sonnet)"

home="$(new_codex_home sync-safety)"
before="$(cat "$home/config.deepseek.toml")"
if run_codex "$home" sync moonbridge >/dev/null 2>&1; then
  fail "sync moonbridge should fail when active config is not Moon Bridge"
fi
after="$(cat "$home/config.deepseek.toml")"
[[ "$before" == "$after" ]] || fail "moonbridge baseline changed after refused sync"

home="$(new_codex_home wrong-yq)"
cat > "$home/codex-providers.yml" <<'EOF'
providers: {}
models: {}
EOF
output="$(run_codex_with_path "$home" "$WRONG_YQ_MOCK_BIN" doctor)"
assert_contains "$output" "WRONG  yq is installed, but not mikefarah/yq v4"

echo "PASS smoke tests"
