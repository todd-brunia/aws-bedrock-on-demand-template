# AWS Bedrock On-Demand Template

A public, account-neutral Terraform template for using Amazon Bedrock from
[OpenCode](https://opencode.ai/) through AWS IAM Identity Center. It creates no
servers, VPCs, agents, knowledge bases, custom models, or provisioned throughput.
Inference is on-demand and pay-per-use.

It works with either a new dedicated workload account or a client-owned AWS
foundation that already has Organizations and IAM resources in place. Existing
client identity resources remain client-owned; the template integrates with
approved roles/OIDC and provisions the Bedrock-specific layers separately.

## Start here: the mental model

This is a client-owned AWS foundation for using approved Bedrock models from a
local OpenCode session. It is **not** a hosted chat application or always-on AI
service: OpenCode runs locally, AWS SSO supplies temporary credentials, and the
selected model is invoked on demand through a narrowly scoped runtime role.

It helps clients get value quickly by combining model choice, low operational
overhead, identity boundaries, cost attribution, and budget alerts. Read the
[mental model and quick start](docs/mental-model.md) before provisioning.

This is an intermediate infrastructure exercise, rather than a first
introduction to AI. It is for people who have already used AI tools (including
hosted coding assistants) and want to evaluate a client-owned, cost-conscious
alternative with more control over model choice, AWS identity, and usage.

For the complete client path—from fork through teardown—follow [client
onboarding](docs/client-onboarding.md).

New to the vocabulary? Start with the [AI and AWS glossary](docs/glossary.md).

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
map; an opt-in starter catalog for Claude, Llama, Mistral, DeepSeek, and Qwen
is available after the preflight checks described in
[model catalog](docs/model-catalog.md).

## Cost planning

Use the [cost estimator](docs/cost-estimator.md) to prepare a rough,
client-specific planning estimate. It separates template control-plane/runtime
costs from Bedrock model-token usage and makes no pricing guarantee.

## OpenCode

OpenCode uses an AWS named SSO profile, not a stored provider key. After apply,
start a source-profile SSO session, render the local config, and launch
OpenCode:

```bash
aws sso login --profile bedrock-admin
state_bucket="$(AWS_PROFILE=bedrock-admin terraform -chdir=infra/bootstrap output -raw state_bucket_name)"
AWS_PROFILE=bedrock-admin ./scripts/render-opencode-config.sh bedrock-pilot "$state_bucket"
opencode
```

The script creates an ignored `opencode.json`. In OpenCode, run `/models`,
select one of the Terraform-provisioned aliases, and send a non-sensitive
prompt. See [OpenCode setup](docs/opencode.md).

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
