# Repository Instructions

## Purpose

This repository is a public, reusable Terraform template for a narrowly scoped,
on-demand Amazon Bedrock foundation. It must remain safe to fork: do not commit
credentials, personal data, client data, real account identifiers, state, plan
artifacts, or generated local OpenCode configuration.

## Authority boundaries

- A human AWS administrator creates the Organizations member account, configures
  IAM Identity Center, owns recovery procedures, reviews Terraform bootstrap,
  and approves protected GitHub deployments.
- GitHub Actions may use short-lived OIDC credentials only through the roles and
  protected environments defined in this repository.
- OpenCode uses a local AWS SSO profile and may invoke only Terraform-approved
  Bedrock inference profiles. Do not introduce static AWS keys, Bedrock bearer
  tokens, or provider credentials.
- Never broaden Bedrock model permissions, trusted principals, OIDC subjects,
  state-bucket access, or workflow authority without an approved issue and
  human review.

## Change governance

After this foundation commit, every tracked-file change requires an issue,
non-default branch, linked pull request, passing validation, and human review.
Do not push directly to `main`, approve or merge your own pull request, create
AWS resources, change repository visibility, publish credentials, or alter
GitHub/AWS authority without explicit human authorization.

## Required validation

Run before requesting review:

```text
terraform fmt -check -recursive
terraform -chdir=infra/bootstrap init -backend=false -input=false
terraform -chdir=infra/bootstrap validate
terraform -chdir=infra/environments/pilot-bedrock init -backend=false -input=false
terraform -chdir=infra/environments/pilot-bedrock validate
terraform -chdir=infra/environments/pilot-iam init -backend=false -input=false
terraform -chdir=infra/environments/pilot-iam validate
```

Also parse changed workflow YAML and run a secret scan. Report blocked checks
truthfully; never substitute a speculative Terraform apply for validation.
