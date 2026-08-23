#!/usr/bin/env bash
set -euo pipefail

global_config_dir="${XDG_CONFIG_HOME:-"${HOME}/.config"}/opencode"
global_config="$global_config_dir/opencode.json"

if [ "$#" -eq 1 ] && [ "$1" = "--clear-global-models" ]; then
  if [ -f "$global_config" ]; then
    temp_config="$(mktemp)"
    jq 'del(.provider["amazon-bedrock"].whitelist, .provider["amazon-bedrock"].models)' \
      "$global_config" > "$temp_config"
    mv "$temp_config" "$global_config"
    echo "Cleared global Amazon Bedrock model aliases from $global_config."
  else
    echo "No global OpenCode config found at $global_config; nothing to clear."
  fi
  exit 0
fi

if [ "$#" -ne 2 ] && [ "$#" -ne 3 ]; then
  echo "Usage: $0 AWS_SSO_PROFILE TF_STATE_BUCKET [--global]" >&2
  echo "       $0 --clear-global-models" >&2
  exit 64
fi

profile="$1"
bucket="$2"
mode="${3:-project}"

if [ "$mode" != "project" ] && [ "$mode" != "--global" ]; then
  echo "Third argument must be --global when provided." >&2
  exit 64
fi
root="$(cd "$(dirname "$0")/.." && pwd)"
stack="$root/infra/environments/pilot-bedrock"

terraform -chdir="$stack" init -input=false -backend-config="bucket=$bucket" >/dev/null
models="$(terraform -chdir="$stack" output -json opencode_models)"

bedrock_provider="$(jq -n --arg profile "$profile" --argjson models "$models" '
  {
    options: { region: "us-east-1", profile: $profile },
    whitelist: ($models | keys),
    models: $models
  }
')"

if [ "$mode" = "--global" ]; then
  mkdir -p "$global_config_dir"
  temp_config="$(mktemp)"
  if [ -f "$global_config" ]; then
    jq --argjson provider "$bedrock_provider" '
      ."$schema" //= "https://opencode.ai/config.json" |
      .provider = (.provider // {}) |
      .provider["amazon-bedrock"] = $provider
    ' "$global_config" > "$temp_config"
  else
    jq -n --argjson provider "$bedrock_provider" '
      {"$schema": "https://opencode.ai/config.json", provider: {"amazon-bedrock": $provider}}
    ' > "$temp_config"
  fi
  mv "$temp_config" "$global_config"
  echo "Merged approved Amazon Bedrock aliases into $global_config."
  exit 0
fi

jq -n --argjson provider "$bedrock_provider" '
  {
    "$schema": "https://opencode.ai/config.json",
    provider: {
      "amazon-bedrock": $provider
    },
    model: "amazon-bedrock/nova-lite"
  }
' > "$root/opencode.json"

echo "Wrote ignored $root/opencode.json. Run aws sso login with the source profile, then opencode and /models."
