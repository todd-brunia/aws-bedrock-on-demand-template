# Security Policy

## Supported version

Security fixes are made on the current `main` branch. Forks are responsible for
their own AWS account, GitHub environment, remote state, IAM principals, budget
notifications, and incident response.

## Reporting a vulnerability

Do not open a public issue for suspected vulnerabilities, exposed credentials,
unsafe Terraform permissions, or a way to bypass the deployment workflow. Use
GitHub's private vulnerability-reporting flow for this repository. Include a
minimal reproduction, affected file or workflow, impact, and remediation idea.
Do not include access keys, tokens, account IDs, private state, prompts, source
dumps, or sensitive client data.

If private reporting is unavailable, contact the repository owner through the
GitHub profile and request a private reporting channel. The maintainer will
assess impact, coordinate a fix, and publish a sanitized advisory after a
reasonable remediation window.

## Security boundaries

- No static AWS credentials or Bedrock bearer tokens are supported. OpenCode
  uses AWS IAM Identity Center temporary credentials.
- Terraform state, `*.tfvars`, generated `opencode.json`, CLI token caches, and
  real account values must stay out of Git history and logs.
- GitHub Actions assumes repository-bound OIDC roles. Apply and destroy require
  a protected environment and human approval.
- The runtime role permits only explicit, Terraform-created inference profiles;
  model additions require a reviewed catalog change.
- AWS Budgets and quotas provide alerts and rate controls, not a hard spending
  cap. Revoke the trusted role or remove inference profiles during an incident.

## Review and disclosure

Review Terraform plans for unexpected IAM, S3, Bedrock, or budget mutations;
inspect workflow changes for credential exposure or untrusted PR access; and run
secret scanning. Security-sensitive changes require an issue, human review, and
a documented rollback or containment action.
