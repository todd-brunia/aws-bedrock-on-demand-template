# Cost estimator: control plane and model inference

## Purpose and limits

This is a directional planning worksheet, not a quote, forecast, commitment,
invoice, or warranty. It does not promise that a workload will cost any
particular amount. AWS pricing, model availability, token accounting,
discounts, taxes, Regions, routing, and client usage can change independently
of this repository.

Use current [Amazon Bedrock pricing](https://aws.amazon.com/bedrock/pricing/),
[Amazon S3 pricing](https://aws.amazon.com/s3/pricing/), and the client's AWS
agreement as the source for rates. Use the [AWS Pricing
Calculator](https://calculator.aws/#/) for a client-specific estimate.

## Template control-plane and runtime cost

The template creates no always-on inference engine: no EC2, Lambda, ECS, API
Gateway, VPC, NAT gateway, database, agent, knowledge base, or provisioned
Bedrock throughput. IAM roles, GitHub OIDC trust, and Bedrock application
inference profiles are control-plane resources, not metered compute instances.

Estimate this portion separately from model use:

| Cost input | Monthly quantity | Current client rate | Estimated monthly cost |
| --- | ---: | ---: | ---: |
| Terraform-state S3 storage, including retained versions | `S_gb_month` GB-month | `R_s3_storage` / GB-month | `S_gb_month × R_s3_storage` |
| S3 state operations (PUT/LIST/GET as applicable) | `N_s3_requests` | `R_s3_request` / request | `N_s3_requests × R_s3_request` |
| Optional state replication, KMS, inventory, logging, or client-required controls | client-specific | client-specific | client-specific |
| AWS Budgets monitoring | current AWS price | current AWS price | current AWS price |
| OpenCode workstation electricity, networking, and staff time | client-specific | client-specific | client-specific |

`control_plane_estimate` is the sum of the last column. In the basic template,
this is normally driven by state storage and request volume, not continuously
running AWS services. Verify the current rules in [AWS Budgets
pricing](https://aws.amazon.com/aws-cost-management/aws-budgets/pricing/).

Exclude pre-existing client Organizations, IAM Identity Center, identity
provider, network, logging, SIEM, support-plan, or shared-platform charges
unless the client explicitly asks to allocate a portion to this workload.

## Bedrock model-inference cost

Model use is the variable portion. Calculate it separately for every selected
model alias and routing mode:

```text
model_estimate =
  (input_tokens       / 1,000,000 × current_input_rate) +
  (output_tokens      / 1,000,000 × current_output_rate) +
  (cache_read_tokens  / 1,000,000 × current_cache_read_rate) +
  (cache_write_tokens / 1,000,000 × current_cache_write_rate) +
  applicable_model_or_routing_fees

monthly_template_estimate = control_plane_estimate + sum(model_estimate)
```

Enter rates only after selecting the actual Bedrock model, Region, service tier,
and inference route. Bedrock can bill input, output, cache-read, and cache-write
tokens separately, and cross-Region routing can change rates. See [Bedrock CUR
cost data](https://docs.aws.amazon.com/bedrock/latest/userguide/cost-mgmt-understanding-cur-data.html).

| Alias/model | Route and Region | Input tokens | Output tokens | Cache read/write tokens | Current rate source | Estimated model cost |
| --- | --- | ---: | ---: | ---: | --- | ---: |
| `nova-lite` | record actual route | `I_1` | `O_1` | `CR_1` / `CW_1` | AWS pricing checked on `DATE` | formula result |
| Optional DeepSeek/Qwen alias | record actual route | `I_2` | `O_2` | `CR_2` / `CW_2` | AWS pricing checked on `DATE` | formula result |

Do not assume models with similar names, parameter counts, or context windows
have comparable rates. A model-catalog change requires a new estimate.

## Make the estimate useful

1. Start with a representative OpenCode workload and record request count,
   input tokens, output tokens, selected aliases, retries, and cache use.
2. Create light, expected, and high scenarios by changing request and token
   volumes, rather than presenting one amount as certain.
3. Add headroom for retries, longer prompts, tool-result context, evaluation
   runs, model switching, and usage growth.
4. Put the selected planning amount into the Terraform monthly-budget input.
   The default `$20` budget is an alerting starting point, not a spending cap.
5. Reconcile this worksheet against Cost Explorer and CUR 2.0 after real use.

Application-inference-profile tags improve attribution, but tags must be
activated in AWS Billing before they appear in cost reporting. Never put client
names, prompt text, credentials, or other sensitive data in tags.

## Client-facing statement

> This worksheet is provided for rough planning only. Actual AWS charges depend
> on models, rates, usage, routing, account terms, taxes, and services selected
> in your account. Review current AWS pricing and your AWS bill before relying
> on any estimate or approving spend.

## Out of scope

This worksheet excludes third-party subscriptions, local-device costs,
engineering time, support plans, taxes, unmodeled data transfer, client-owned
shared infrastructure, and services added outside this template. Estimate any
future hosted runtimes, agents, knowledge bases, model customization, or
provisioned throughput separately.
