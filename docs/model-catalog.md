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

For every candidate, while authenticated to the workload account:

1. Check the current Bedrock model catalog, supported Region, pricing, and
   provider terms. Confirm it supports the API path OpenCode uses.
2. Confirm access with a minimal non-sensitive prompt using the exact model or
   system inference profile identifier.
3. Derive the exact `model_source_arn` accepted by `CreateInferenceProfile`.
   Direct models use a foundation-model ARN; cross-Region choices may need the
   applicable system inference profile ARN.
4. Add a descriptive alias and exact source ARN to
   `infra/environments/pilot-bedrock/model-catalog.tfvars` in a reviewed pull
   request, then run the protected apply workflow.
5. Regenerate the ignored OpenCode config and use `/models` to test the alias.

Start with `nova-lite`. DeepSeek and Qwen are intended candidates, not permanent
facts: model IDs, pricing, regional support, and EULA requirements can change.
Never use `*` in the runtime inference policy to make an unreviewed model work.
