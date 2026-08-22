# Contributing

Thanks for helping improve this public Terraform template. Contributions should
make the template safer, clearer, and easier to fork without introducing
account-specific assumptions.

## Before opening a pull request

1. Search existing issues and open an issue describing the problem, proposed
   outcome, security impact, and how the change will be validated.
2. Create a non-default branch. Do not push directly to `main`.
3. Keep examples synthetic. Never commit AWS account IDs, root emails, recovery
   contacts, state buckets, `*.tfvars`, credentials, SSO caches, OpenCode local
   configuration, Terraform plans, or client data.
4. Keep IAM and Bedrock resources in their separate state stacks. Do not grant
   wildcard model invocation, static AWS credentials, or unreviewed principals.

## Required checks

Run the checks in [AGENTS.md](AGENTS.md), plus any relevant documentation or
workflow checks. Include results in the pull request and clearly note blocked
checks. A reviewer must approve before merge.

## Model catalog changes

Model additions require current verification of AWS regional availability,
provider terms, API/OpenCode compatibility, pricing, and rollback behavior.
Update the reviewed Terraform catalog and documentation together; do not add a
model by changing only local OpenCode configuration.

## Security reports

Use [SECURITY.md](SECURITY.md) for vulnerability reporting. Do not disclose
security issues in public issues or pull requests before remediation.
