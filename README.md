# AWS Bedrock On-Demand Template

A public, account-neutral Terraform template for using Amazon Bedrock from
[OpenCode](https://opencode.ai/) through AWS IAM Identity Center. It creates no
servers, VPCs, agents, knowledge bases, custom models, or provisioned throughput.
Inference is on-demand and pay-per-use.

## What this provisions

1. A one-time Terraform state and GitHub OIDC bootstrap.
2. Tagged, model-specific Bedrock application inference profiles and a Bedrock
   budget.
3. A separate IAM runtime role that can invoke only those profile ARNs.

`infra/bootstrap`, `infra/environments/pilot-bedrock`, and
`infra/environments/pilot-iam` deliberately use separate Terraform states. The
Bedrock stack is applied before IAM; IAM is destroyed before Bedrock.

## Before starting

Follow [the account foundation guide](docs/aws-account-foundation.md), then
[the bootstrap runbook](docs/bootstrap-and-deploy.md). Do not put an AWS account
ID, root email, AWS key, Bedrock bearer token, state bucket name, or notification
email into tracked files.

Read [SECURITY.md](SECURITY.md) before deploying or reporting a vulnerability.
See [CONTRIBUTING.md](CONTRIBUTING.md) for the public contribution workflow.

The default example model is Amazon Nova Lite. The model catalog is an explicit
map so an operator can add currently supported DeepSeek or Qwen candidates only
after the preflight checks described in [model catalog](docs/model-catalog.md).

## Cost planning

Use the [cost estimator](docs/cost-estimator.md) to prepare a rough,
client-specific planning estimate. It separates template control-plane/runtime
costs from Bedrock model-token usage and makes no pricing guarantee.

## OpenCode

OpenCode uses an AWS named SSO profile, not a stored provider key. After apply:

```bash
aws sso login --profile bedrock-pilot
./scripts/render-opencode-config.sh bedrock-pilot
opencode
```

The script creates an ignored `opencode.json`. In OpenCode, run `/models` and
select one of the Terraform-provisioned aliases. See
[OpenCode setup](docs/opencode.md).

## Validation

```bash
terraform -chdir=infra/bootstrap init -backend=false
terraform -chdir=infra/bootstrap validate
terraform -chdir=infra/environments/pilot-bedrock init -backend=false
terraform -chdir=infra/environments/pilot-bedrock validate
terraform -chdir=infra/environments/pilot-iam init -backend=false
terraform -chdir=infra/environments/pilot-iam validate
```

GitHub Actions performs these checks on pull requests. Protected manual workflows
perform remote plan, apply, and destroy using GitHub OIDC.
