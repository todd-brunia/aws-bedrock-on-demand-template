#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 AWS_SSO_PROFILE TF_STATE_BUCKET" >&2
  exit 64
fi

profile="$1"
bucket="$2"
root="$(cd "$(dirname "$0")/.." && pwd)"
stack="$root/infra/environments/pilot-bedrock"

terraform -chdir="$stack" init -input=false -backend-config="bucket=$bucket" >/dev/null
profiles="$(terraform -chdir="$stack" output -json inference_profile_arns)"

jq --arg profile "$profile" --argjson models "$profiles" '
  {
    "$schema": "https://opencode.ai/config.json",
    provider: {
      "amazon-bedrock": {
        options: { region: "us-east-1", profile: $profile },
        models: ($models | with_entries({key: .key, value: {id: .value}}))
      }
    },
    model: "amazon-bedrock/nova-lite"
  }
' > "$root/opencode.json"

echo "Wrote ignored $root/opencode.json. Run aws sso login --profile $profile, then opencode and /models."
