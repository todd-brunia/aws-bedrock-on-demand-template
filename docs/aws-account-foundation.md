# AWS account foundation

This template supports two starting points:

- **New workload account:** create a dedicated member account from the AWS
  Organizations management account. Do not provision Bedrock resources in the
  management account.
- **Client-provided foundation:** use an existing approved workload account and
  integrate with the client's established AWS Organizations, IAM Identity
  Center, IAM roles, and GitHub OIDC provider. The template provisions only its
  Bedrock profiles, budget, narrowly scoped runtime role, and dedicated
  Terraform control-plane resources; it does not take ownership of or modify
  the client's existing organization or identity foundation.

For a client-provided foundation, document the approved account, administrator
permission set, trusted workload role ARNs, existing OIDC-provider ARN, and
state-bucket custody with the client. Set `github_oidc_provider_arn` during
bootstrap to adopt the existing GitHub OIDC provider rather than creating a
duplicate. Do not import, alter, or destroy client-owned IAM/organization
resources unless a separate reviewed engagement explicitly authorizes it.

For a new workload account, complete the following steps:

1. Choose a unique, recoverable root email for the new workload account and
   create it in AWS Organizations. Retain the organization access role.
2. Enable root MFA, confirm recovery contacts, and create no root access keys.
3. In IAM Identity Center, assign an MFA-protected administrator permission set
   to the workload account. Verify a non-root login in `us-east-1`.
4. Create a management-account budget scoped to the member account where
   available. This catches accidental non-Bedrock charges; the Terraform budget
   covers Amazon Bedrock usage separately.
5. Configure a named SSO profile, log in, and verify the account privately:

   ```bash
   aws configure sso --profile bedrock-admin
   aws sso login --profile bedrock-admin
   aws sts get-caller-identity --profile bedrock-admin
   ```

6. Create or identify the existing workload role that will be allowed to assume
   `bedrock-on-demand-pilot-runtime`. For local OpenCode, this is commonly the
   approved IAM Identity Center role ARN. Supply it as
   `TRUSTED_WORKLOAD_ROLE_ARNS_JSON` only in the protected GitHub environment.

Keep account IDs, recovery contacts, and the AWS access portal in KeePassXC,
not in the repository.
