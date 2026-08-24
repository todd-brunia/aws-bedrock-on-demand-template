# Model catalog

Each selectable OpenCode model is an explicit Terraform catalog entry and a
Bedrock application inference profile. This gives model-level IAM permissions
and cost attribution. Adding a model is not an OpenCode-only configuration
change.

Start with [Amazon Nova](https://docs.aws.amazon.com/nova/latest/userguide/what-is-nova.html)
only as the reviewed example, not as the sole supported choice. Consult the
[Amazon Bedrock model catalog](https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html)
and [inference profile documentation](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles.html)
when evaluating another provider or model family.

## Opt-in multi-provider starter catalog

`infra/environments/pilot-bedrock/model-catalog-multi-provider.example.tfvars`
contains one streaming text model each from Amazon, Anthropic, Meta, Mistral,
DeepSeek, and Qwen that was found active in the pilot account's `us-east-1`
catalog during this template validation. It is an example file and is not
loaded by Terraform, so merging it creates no profiles and no cost.

Select one or more entries only after the preflight below, then copy them into
the tracked `model-catalog.tfvars` in a reviewed pull request. The example uses
conservative OpenCode context and output caps to limit initial usage; revisit
them after a model-specific evaluation. Recheck availability, pricing, and
provider terms immediately before every enablement because the Bedrock catalog
changes over time.

Amazon Titan and Cohere are intentionally not in this OpenCode chat catalog:
the validated regional inventory exposed Titan embeddings and Cohere
embedding/reranking models, rather than streaming conversational models.

## Find and add a new OpenCode model

Use the workload administrator profile to inspect the live regional catalog;
do not copy an identifier from an old blog post or another Region:

```bash
AWS_PROFILE=bedrock-admin aws bedrock list-foundation-models \
  --region us-east-1 \
  --by-output-modality TEXT \
  --query 'modelSummaries[?modelLifecycle.status==`ACTIVE`].{provider:providerName,name:modelName,id:modelId,streaming:responseStreamingSupported}' \
  --output table
```

Choose a model with `streaming` set to `True` for OpenCode. Inspect the
candidate without invoking it:

```bash
model_id='REPLACE_WITH_MODEL_ID'
AWS_PROFILE=bedrock-admin aws bedrock get-foundation-model \
  --region us-east-1 \
  --model-identifier "$model_id"
```

Then follow this sequence:

1. Read the current AWS model card, pricing page, and provider terms. In the
   Bedrock console's **Model catalog**, complete any required access request or
   Marketplace subscription for the workload account. Do not accept terms on
   behalf of a client without their authorization.
2. Confirm the model supports the Bedrock runtime path OpenCode uses. For a
   direct regional model, set `model_source_arn` to
   `arn:aws:bedrock:us-east-1::foundation-model/<model-id>`. If AWS requires a
   cross-Region system inference profile, set
   `system_inference_profile_id` to the exact profile ID AWS reports (for
   example, `us.anthropic.claude-sonnet-4-6`). Terraform derives the
   account-specific ARN from `aws_account_id`; do not commit an account ID.
3. Start with a conservative output cap (for example, 1,024 tokens) and a
   context value no larger than the documented model limit. These values become
   the generated OpenCode limits and can be increased later through review.
4. Add only that entry to the tracked
   `infra/environments/pilot-bedrock/model-catalog.tfvars` in a pull request.
   Do not edit the generated `opencode.json` to add a model.
5. After review and the protected Terraform apply, regenerate `opencode.json`,
   start OpenCode, run `/models`, and choose `amazon-bedrock/<alias>`. Make one
   short non-sensitive test request and record the result and observed cost.

To keep cost and troubleshooting scope small, enable and test one new model at
a time. Remove its catalog entry and run the protected apply if it is not an
approved ongoing option.

For every candidate, while authenticated to the workload account:

1. Check the current Bedrock model catalog, supported Region, pricing, and
   provider terms. Confirm it supports the API path OpenCode uses.
2. Confirm access with a minimal non-sensitive prompt using the exact model or
   system inference profile identifier.
3. Derive the exact source accepted by `CreateInferenceProfile`. Direct models
   use `model_source_arn` with a foundation-model ARN; cross-Region choices use
   `system_inference_profile_id` so Terraform can derive the applicable
   account-specific system inference-profile ARN without committing it.
4. Record the documented context-window and maximum-output-token limits. The
   generated OpenCode configuration uses these limits to avoid sending a
   request that Bedrock will reject.
5. Add a descriptive alias, one exact source form, and both limits to
   `infra/environments/pilot-bedrock/model-catalog.tfvars` in a reviewed pull
   request, then run the protected apply workflow. This file is intentionally
   tracked because it is the reviewed public catalog; use the ignored
   `terraform.tfvars` or `*.auto.tfvars` files only for account-specific values.
6. Regenerate the ignored OpenCode config and use `/models` to test the alias.

Start with `nova-lite`. DeepSeek and Qwen are intended candidates, not permanent
facts: model IDs, pricing, regional support, and EULA requirements can change.
Never use `*` in the runtime inference policy to make an unreviewed model work.
