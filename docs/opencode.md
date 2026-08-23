# OpenCode setup

OpenCode supports [Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html)
through an AWS named profile; see the [OpenCode provider documentation](https://opencode.ai/docs/providers)
for its current provider configuration. Use AWS IAM Identity Center credentials
so OpenCode receives only temporary credentials.
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

The generated configuration whitelists only aliases whose Terraform inference
profiles were successfully provisioned. In OpenCode, use `/models` and select
`amazon-bedrock/nova-lite`; do not change a profile ARN manually to bypass the
approved catalog.

## Everyday start and stop

From the repository root, after the Bedrock and IAM stacks have been applied:

```bash
aws sso login --profile bedrock-admin
state_bucket="$(AWS_PROFILE=bedrock-admin terraform -chdir=infra/bootstrap output -raw state_bucket_name)"
AWS_PROFILE=bedrock-admin ./scripts/render-opencode-config.sh bedrock-pilot "$state_bucket"
opencode
```

In OpenCode, run `/models` and choose an `amazon-bedrock/<alias>` listed in the
generated configuration. Use a short, non-sensitive prompt for a first test.
Exit OpenCode when finished. Running OpenCode locally has no idle Bedrock cost;
the chosen model is billed only when a request is sent. To remove the deployed
profiles, runtime role, and budget when the environment is no longer needed,
run the protected **Terraform destroy** workflow and type `DESTROY BEDROCK
PILOT`.

Before starting OpenCode, confirm that the source role behind `bedrock-pilot`
has permission to call `sts:AssumeRole` on
`bedrock-on-demand-pilot-runtime`. The runtime role's trust policy does not
grant that source-side permission.
