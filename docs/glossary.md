# AI and AWS glossary

This is a quick reference for readers who are already exploring AI tools and
want to take the next step: running approved models through their own AWS
account with clearer access and cost boundaries. It is not intended to teach AI
or AWS from zero. Start with the [mental model](mental-model.md) for the
architecture and [client onboarding](client-onboarding.md) for the workflow.

## AI and Bedrock terms

| Term | Plain-language meaning | How it relates here |
| --- | --- | --- |
| [Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html) | AWS's managed service for accessing foundation models. | It is the model service this template configures access to; it is not a server that you operate. |
| [Foundation model](https://docs.aws.amazon.com/bedrock/latest/userguide/foundation-models.html) | A general-purpose model trained in advance, which can be prompted for tasks such as writing, analysis, or coding. | The model catalog limits which foundation models an OpenCode user may invoke. |
| [Amazon Nova](https://docs.aws.amazon.com/nova/latest/userguide/what-is-nova.html) | Amazon's family of foundation models available through Bedrock. | `nova-lite` is the reviewed starting example, not a requirement to use Nova forever. |
| Model catalog | The approved list of model aliases and exact source identifiers. | Changing it is a Terraform and review decision, not merely a local OpenCode setting. |
| [Inference profile](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles.html) | A Bedrock resource that routes model requests and can carry tags for tracking. | The template creates application inference profiles and grants the runtime role access only to them. |
| On-demand inference | Paying for a model request when it runs, rather than reserving always-available model capacity. | This keeps the template free of persistent compute, but every prompt still has model-usage cost. |
| Prompt | The instructions and input sent to a model. | Send only client-approved, non-sensitive material through the selected model and route. |
| Response | The model output returned for a prompt. | Treat it as a draft to review, especially for code, decisions, or factual statements. |
| Token | A small unit of text a model processes; pricing commonly counts input and output tokens. | Use the [cost estimator](cost-estimator.md) to make a rough planning estimate from expected token use. |
| Context window | The amount of prompt and prior conversation information a model can consider at once. | A larger context can help with larger tasks but can also increase input-token use. |
| Hallucination | A confident-sounding model answer that is wrong, unsupported, or invented. | Human review remains necessary; this template does not validate model outputs. |
| Prompt injection | Instructions embedded in supplied content that try to redirect a model from the user's intended task. | Treat untrusted content carefully and do not grant AI tools authority beyond what a human reviewer accepts. |
| RAG (retrieval-augmented generation) | An application pattern that retrieves relevant documents before prompting a model. | This template does not create a knowledge base, vector store, or RAG pipeline; those require separate design. |
| AI agent | Software that can take multi-step actions using a model and tools. | This template provides direct model access from OpenCode, not an autonomous agent platform. |

## Identity, infrastructure, and cost terms

| Term | Plain-language meaning | How it relates here |
| --- | --- | --- |
| [AWS account](https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-creating.html) | An isolated AWS billing and security boundary. | You can use a dedicated workload account or integrate with an existing client account foundation. |
| [AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html) | AWS service for centrally managing multiple AWS accounts. | A client may create a member workload account, or retain their existing organization arrangement. |
| [IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html) | AWS Identity and Access Management: the system that defines who may do what. | IAM resources are deliberately separated from Bedrock resources into their own Terraform state. |
| [IAM Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html) / SSO | AWS's workforce sign-in service for short-lived, centrally managed access. | OpenCode starts from a named SSO profile rather than a permanent AWS key. |
| IAM role | A set of AWS permissions that a trusted identity can assume temporarily. | The runtime role can invoke approved inference profiles but cannot provision infrastructure. |
| Temporary credentials | Credentials that expire after a limited session. | AWS SSO and role assumption supply them; they should not be stored in KeePassXC or committed. |
| [OIDC](https://docs.github.com/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect) | A standards-based way for one service to prove its identity to another without a long-lived shared secret. | GitHub Actions uses OIDC to assume tightly scoped Terraform deployment roles. |
| [Terraform](https://developer.hashicorp.com/terraform/intro) | Infrastructure-as-code software that describes and changes cloud resources. | Terraform creates and removes this template's state bucket, Bedrock profiles, budget, and IAM runtime role. |
| [Terraform state](https://developer.hashicorp.com/terraform/language/state) | Terraform's record of the resources it manages. | Each layer has separate remote state so IAM and Bedrock lifecycle changes remain bounded. |
| [GitHub Actions](https://docs.github.com/actions) | GitHub's workflow automation service. | Protected manual workflows plan, apply, and destroy reviewed Terraform changes. |
| [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) | AWS object storage. | The bootstrap layer creates a private bucket for Terraform state, not for prompt data or model output. |
| Least privilege | Granting only the permissions needed for a task. | The runtime role is limited to the approved Bedrock inference profile ARNs. |
| Budget alert | An AWS notification when estimated or actual spending reaches a threshold. | It is an early warning, not a hard spending cap; monitor actual costs too. |
| Destroy | Removing Terraform-managed resources with `terraform destroy`. | The protected workflow removes runtime IAM first, then Bedrock resources; it does not close the AWS account. |

## Useful official references

- [KeePassXC](https://keepassxc.org/) for the local password manager used to
  record recovery and configuration information.
- [OpenCode providers](https://opencode.ai/docs/providers) for current local
  provider configuration and model-selection behavior.
- [Amazon Bedrock pricing](https://aws.amazon.com/bedrock/pricing/) for current
  model prices; use it instead of treating this repository's estimator as a quote.
- [AWS CLI IAM Identity Center configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
  for configuring the local SSO profile used by OpenCode.
