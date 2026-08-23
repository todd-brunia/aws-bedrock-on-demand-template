# Client onboarding: fork, provision, use, and remove

This guide is the end-to-end path for a client that wants to use this template
in an AWS account it controls. Complete it with an authorized AWS administrator
and GitHub repository administrator. Do not place real account details,
credentials, SSO tokens, state, or generated `opencode.json` in the fork.

## 1. Fork and review

1. Fork this repository into the client's GitHub owner or organization.
2. Clone the fork locally and read [SECURITY.md](../SECURITY.md),
   [the mental model](mental-model.md), [the AI and AWS glossary](glossary.md),
   and [the cost estimator](cost-estimator.md).
3. Decide the initial model catalog, budget notification owner, trusted
   workload role, and who will approve the GitHub `pilot` environment.
4. Keep the fork's `main` branch protected. Use pull requests for all changes,
   including model-catalog and IAM changes.

## 2. Choose the AWS foundation path

### New workload account

Follow [AWS account foundation](aws-account-foundation.md) to create a dedicated
Organizations member account, configure root recovery/MFA and IAM Identity
Center, and record the recovery and access details in KeePassXC.

### Existing client AWS foundation

If the client already has an approved AWS workload account, AWS Organizations,
IAM Identity Center, roles, and/or GitHub OIDC provider, skip account creation
and use those approved resources. Record the account ID, administrator access,
approved workload-role ARN, existing OIDC-provider ARN, and state-bucket owner
with the client. Do not modify, import, or destroy client-managed identity or
organization resources through this template.

In either path, use `us-east-1` for this pilot and obtain an IAM Identity Center
AWS CLI profile with sufficient bootstrap authority. Confirm it privately:

```bash
aws sso login --profile bedrock-admin
aws sts get-caller-identity --profile bedrock-admin
```

## 3. Bootstrap the Terraform control plane

The bootstrap is the one local Terraform apply. It creates a dedicated state
bucket and repository-bound GitHub OIDC plan/apply roles. It does not create
Bedrock model access yet.

1. Copy `infra/bootstrap/terraform.tfvars.example` to the ignored
   `infra/bootstrap/terraform.tfvars` and fill in the client workload account,
   unique state-bucket name, and exact GitHub OIDC subject prefix. Obtain the
   prefix with `gh api repos/OWNER/REPOSITORY/actions/oidc/customization/sub
   --jq .sub_claim_prefix`; do not derive it manually from the repository name.
2. If the workload account already has GitHub OIDC, set
   `github_oidc_provider_arn`; this adopts it instead of creating another one.
3. Review and apply a saved plan:

   ```bash
   AWS_PROFILE=bedrock-admin terraform -chdir=infra/bootstrap init -backend=false
   AWS_PROFILE=bedrock-admin terraform -chdir=infra/bootstrap plan -out=bootstrap.tfplan
   AWS_PROFILE=bedrock-admin terraform -chdir=infra/bootstrap apply bootstrap.tfplan
   ```

4. Store the bootstrap outputs and recovery information in KeePassXC. Do not
   commit the local tfvars or plan file.

See [bootstrap and deploy](bootstrap-and-deploy.md) for further safeguards.

## 4. Configure the fork's GitHub Actions

In the fork's GitHub settings, create environments named `pilot` and
`pilot-plan`. Require one or more client approvers for `pilot`; only `pilot` can
apply or destroy resources.

Set these repository/environment variables from the bootstrap outputs and the
client account inventory:

| Variable | Value |
| --- | --- |
| `AWS_ACCOUNT_ID` | the 12-digit workload account ID |
| `TF_STATE_BUCKET` | the bootstrap state-bucket name |
| `AWS_TERRAFORM_PLAN_ROLE_ARN` | bootstrap `github_plan_role_arn` output |
| `AWS_TERRAFORM_APPLY_ROLE_ARN` | bootstrap `github_apply_role_arn` output |
| `TRUSTED_WORKLOAD_ROLE_ARNS_JSON` | `pilot` environment variable: JSON array containing approved local/workload role ARN(s) |

Add `BUDGET_NOTIFICATION_EMAIL` as a GitHub environment secret, not a variable.
For example, the trusted-role value has this shape:

```json
["arn:aws:iam::123456789012:role/CLIENT_APPROVED_WORKLOAD_ROLE"]
```

Never configure access keys or Bedrock bearer tokens in GitHub Actions.
Each listed source role must separately have `sts:AssumeRole` permission for
`bedrock-on-demand-pilot-runtime`; the runtime role's trust policy alone does
not grant it.

## 5. Select the initial model and provision

1. Start with the reviewed `nova-lite` catalog entry. For another model, follow
   [model catalog](model-catalog.md) and make the catalog change in a reviewed
   pull request.
2. Open or update a pull request. The Terraform validation and remote-plan
   workflows should complete without granting AWS credentials to fork PRs. The
   remote-plan job uses the protected `pilot-plan` environment.
3. Merge the reviewed change to `main`.
4. In **Actions**, run **Terraform apply**, providing the exact current `main`
   commit SHA. A protected `pilot` approver reviews the environment request.
5. The workflow applies a saved Bedrock plan first and a saved IAM plan second.
   It rejects unintended delete actions. Confirm the budget and inference
   profile exist before continuing.

## 6. Connect OpenCode and verify the first request

Configure a local role-chaining AWS profile after the IAM stack is present. See
[OpenCode setup](opencode.md) for the profile format.

```bash
aws sso login --profile bedrock-admin
./scripts/render-opencode-config.sh bedrock-pilot REPLACE_TF_STATE_BUCKET
opencode
```

In OpenCode:

1. Run `/models` and select `amazon-bedrock/nova-lite`.
2. Send this non-sensitive smoke prompt:

   ```text
   Reply with exactly: Bedrock configuration verified.
   ```

3. Confirm the exact reply and record the selected model alias, date, and token
   use in the [cost estimator](cost-estimator.md). This request incurs normal
   on-demand model usage, so keep it small.

If OpenCode cannot invoke the model, recheck the SSO session, role chain,
trusted-role ARN, application inference profile ARN, model access/terms, and
the selected Region. Do not work around a denial by adding broad Bedrock IAM
permissions. An inference-profile invocation policy must also permit the
underlying foundation-model ARN, conditioned on the matching inference-profile
ARN; this template manages that pairing in the IAM stack.

## 7. Operate and remove resources

Use OpenCode only with approved models and data. Review the budget alerts and
actual AWS cost data regularly; alerts are not a hard spending limit.

When the client wants to stop using the template:

1. In **Actions**, run **Terraform destroy** and type
   `DESTROY BEDROCK PILOT` exactly.
2. Have a `pilot` environment approver authorize it. The workflow destroys IAM
   runtime access first, then Bedrock profiles and the template budget.
3. Retain the bootstrap state/OIDC controls for future reuse, or follow the
   separate, human-approved account and bootstrap retirement procedure in
   [bootstrap and deploy](bootstrap-and-deploy.md).

Destroying these template resources does not close a client account or remove
client-owned identity, organization, network, logging, or other shared AWS
resources.
