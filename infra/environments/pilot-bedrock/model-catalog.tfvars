# This file is safe to commit. Add exact, preflight-verified source ARNs here in
# a reviewed pull request when enabling a new model alias.
model_catalog = {
  nova-lite = {
    model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-lite-v1:0"
    description           = "Low-cost default text model."
    context_window_tokens = 300000
    max_output_tokens     = 5000
  }
}
