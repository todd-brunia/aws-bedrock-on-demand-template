# KeePassXC setup

[KeePassXC](https://keepassxc.org/) is a local, open-source password manager.
Use it to record recovery and configuration information that a human administrator
needs, not as a place to copy active AWS credentials or session tokens. Create a
dedicated KeePassXC database or group named `AWS Bedrock On-Demand`.
Protect it with a strong unique passphrase and a separate key file stored away
from the database. Keep the database and key file in independently backed-up
locations.

Create these entries:

| Entry | Store | Do not store |
| --- | --- | --- |
| Management account recovery | root recovery email/contact, MFA device location, billing owner | root access keys |
| Bedrock workload recovery | member-account root recovery information and account ID | root password in notes or access keys |
| IAM Identity Center | access portal URL, region, account, permission set, profile name | SSO cache or browser/session tokens |
| Terraform bootstrap | state bucket, OIDC role ARNs, bootstrap operator and review date | Terraform state or plan files |
| GitHub deployment | repository/environment names, approvers, budget notification owner | GitHub personal tokens or Actions secrets |

Create entries manually during account setup; never paste their contents into
issues, pull requests, prompts, committed files, or workflow logs. AWS SSO
tokens remain in the AWS CLI-managed cache and expire; they do not belong in
KeePassXC. Bedrock bearer tokens and long-lived IAM credentials are outside this
design and must not be created for OpenCode.
