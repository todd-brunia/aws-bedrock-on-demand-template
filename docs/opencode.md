# OpenCode setup

OpenCode supports Amazon Bedrock through an AWS named profile. Use AWS IAM
Identity Center credentials so OpenCode receives only temporary credentials.
Do not use `/connect`, `AWS_BEARER_TOKEN_BEDROCK`, or AWS access keys for this
repository: a stored bearer token can override the intended profile chain.

Create a role-chaining profile after the IAM stack exists:

```ini
# ~/.aws/config (local, never committed)
[profile bedrock-pilot]
role_arn = arn:aws:iam::REPLACE_ACCOUNT_ID:role/bedrock-on-demand-pilot-runtime
source_profile = bedrock-admin
region = us-east-1
```

Log in and generate the ignored local configuration:

```bash
aws sso login --profile bedrock-admin
./scripts/render-opencode-config.sh bedrock-pilot REPLACE_TF_STATE_BUCKET
opencode
```

OpenCode's `/models` menu contains only aliases whose Terraform inference
profiles were successfully provisioned. Switch models there; do not change a
profile ARN manually to bypass the approved catalog.
