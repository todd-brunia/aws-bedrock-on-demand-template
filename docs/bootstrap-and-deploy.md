# Bootstrap, deploy, and teardown

## Bootstrap

Bootstrap is the one intentional local Terraform apply. It establishes the
remote state bucket and GitHub OIDC roles that later workflows need. Review a
saved plan using an IAM Identity Center session; never use an access key.

```bash
cp infra/bootstrap/terraform.tfvars.example infra/bootstrap/terraform.tfvars
aws sso login --profile bedrock-admin
AWS_PROFILE=bedrock-admin terraform -chdir=infra/bootstrap init -backend=false -input=false
AWS_PROFILE=bedrock-admin terraform -chdir=infra/bootstrap plan -out=bootstrap.tfplan
AWS_PROFILE=bedrock-admin terraform -chdir=infra/bootstrap apply bootstrap.tfplan
```

If GitHub OIDC already exists, set `github_oidc_provider_arn` first. Do not
create a second account-level provider.

Configure protected GitHub environments named `pilot` and `pilot-plan`; require
human reviewers for `pilot`. Set repository variables: `AWS_ACCOUNT_ID`,
`TF_STATE_BUCKET`, `AWS_TERRAFORM_PLAN_ROLE_ARN`, and
`AWS_TERRAFORM_APPLY_ROLE_ARN`. Set `TRUSTED_WORKLOAD_ROLE_ARNS_JSON` as a
`pilot` environment variable and `BUDGET_NOTIFICATION_EMAIL` as a `pilot`
environment secret. Use JSON for the trusted roles, for example
`["arn:aws:iam::123456789012:role/approved-role"]`.

## Deploy

Merge a reviewed catalog change, then dispatch **Terraform apply** from the
current `main` commit. The workflow creates Bedrock profiles first, then the
runtime IAM role. Review the GitHub Environment prompt before approving.

## Destroy

Dispatch **Terraform destroy** and type `DESTROY BEDROCK PILOT`. It destroys
runtime IAM first and Bedrock profiles/budget second. It intentionally retains
the remote state bucket and OIDC roles. The retained IAM/OIDC controls do not
run compute, but the versioned S3 state bucket can incur small storage and
request charges. Destroy the pilot when testing is complete to prevent future
model invocation; retain bootstrap only if future use is intended. To retire
the account completely, disable workflows, preserve/export state evidence,
obtain human approval, then remove bootstrap protections and close the member
account through AWS's documented account-closure process.
