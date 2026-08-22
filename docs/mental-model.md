# Mental model and quick start

## What this is

This repository is a reusable AWS foundation for using approved Amazon Bedrock
models from local [OpenCode](https://opencode.ai/) sessions. It is not a hosted
chat application, model proxy, autonomous agent, or always-running inference
service. Your prompts start on your local machine; AWS authenticates the session
and meters the selected model's on-demand usage.

```text
You + OpenCode on your workstation
        │ AWS IAM Identity Center temporary credentials
        ▼
Approved client/workload role
        │ assume-role
        ▼
Bedrock runtime role ──► tagged application inference profile ──► approved model

GitHub Actions + OIDC ──► Terraform control plane
                              │ creates/updates only
                              ▼
                   profiles, budget, and runtime IAM role
```

The two paths are intentionally separate. OpenCode can use approved models but
cannot provision AWS infrastructure. GitHub Actions can provision the reviewed
Terraform configuration but cannot become a general model runtime.

## What value it provides

- **Low operational overhead:** on-demand inference means no servers or
  provisioned model capacity to keep running when nobody is using it.
- **Choice with boundaries:** Nova Lite is the starting catalog entry; approved
  DeepSeek, Qwen, or other compatible Bedrock models can be added through a
  reviewed model-catalog change.
- **Client ownership:** it works with a new account or with the client's
  existing Organizations, IAM Identity Center, roles, and OIDC provider without
  taking ownership of those established resources.
- **Safer experimentation:** short-lived SSO credentials, narrowly scoped model
  access, application-inference-profile tags, and budget alerts make it easier
  to test models without distributing provider keys.

## Good-fit use cases

This arrangement is especially useful for interactive, human-led work where a
developer or knowledge worker wants to select an approved model from OpenCode
without operating a separate AI platform.

- **Software development and coding:** explore an unfamiliar codebase, draft or
  review a change, explain an error, generate tests, refactor with human review,
  or compare an approved model's response to another model.
- **Technical and operational writing:** turn approved, non-sensitive notes into
  outlines, runbooks, checklists, release notes, or first-pass documentation.
- **Research and analysis:** summarize material the client is permitted to send
  to the selected model, structure options, identify follow-up questions, or
  compare approaches before a human decision.
- **Controlled model evaluation:** test a small representative prompt set across
  approved Bedrock models, record token use and quality observations, then use
  that evidence to decide whether a model belongs in the catalog.

It is not intended to make unsupervised production decisions, process data that
has not been approved for the selected model/route, replace code review, or
serve a public application. Those needs require additional application,
security, privacy, and operational design beyond this template.

## Fastest safe path to first value

1. Decide whether to use a new workload account or an approved existing client
   account; follow the [account foundation](aws-account-foundation.md) guide.
2. Bootstrap remote Terraform state and GitHub OIDC, adopting an existing OIDC
   provider where appropriate.
3. Apply the reviewed default Nova Lite catalog and confirm the Bedrock budget
   notification recipient.
4. Configure the local SSO role chain and generate ignored `opencode.json` as
   described in [OpenCode setup](opencode.md).
5. Run a small, non-sensitive OpenCode task, select `nova-lite` with `/models`,
   and verify the result and AWS attribution before increasing use.
6. Record observed token use in the [cost estimator](cost-estimator.md), then
   add another model only when its capability, route, pricing, and terms have
   been reviewed.

## What clients still own

The client decides which prompts and source material may leave their
environment, which models are approved, who may assume the runtime role, how
much spend is acceptable, and how incidents are handled. Budget alerts are not
a hard spending cap. This template does not replace security review, data
classification, legal/procurement review, or application-specific controls.

## A plain-language way to describe it

> This is a lightweight, client-owned AWS foundation for trying approved AI
> models through OpenCode. It avoids always-on AI infrastructure, keeps access
> tied to the client's AWS identity controls, and makes model use and costs
> easier to review. The client still chooses what data to use, which models to
> permit, and what spending level is acceptable.
