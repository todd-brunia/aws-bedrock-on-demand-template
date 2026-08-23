# Opt-in starter catalog for OpenCode chat. Before using any entry, confirm the
# current AWS pricing, regional availability, provider terms, and model access
# in the workload account. Copy selected entries—not necessarily all of them—
# into model-catalog.tfvars in a reviewed pull request.
#
# The limits below are intentionally conservative OpenCode operating caps. They
# are not claims about the providers' maximum supported context or output.
model_catalog = {
  nova-lite = {
    model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-lite-v1:0"
    description           = "Low-cost Amazon baseline for short text and tool-use tests."
    context_window_tokens = 300000
    max_output_tokens     = 5000
  }
  claude-haiku-4-5 = {
    model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-haiku-4-5-20251001-v1:0"
    description           = "Fast Anthropic Claude option with a conservative output cap."
    context_window_tokens = 32768
    max_output_tokens     = 1024
  }
  llama-3-1-8b = {
    model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/meta.llama3-1-8b-instruct-v1:0"
    description           = "Smaller Meta Llama instruct option for cost-conscious comparison."
    context_window_tokens = 32768
    max_output_tokens     = 1024
  }
  ministral-3-3b = {
    model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/mistral.ministral-3-3b-instruct"
    description           = "Small Mistral instruct option for cost-conscious comparison."
    context_window_tokens = 32768
    max_output_tokens     = 1024
  }
  deepseek-r1 = {
    model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/deepseek.r1-v1:0"
    description           = "DeepSeek reasoning option; review terms and pricing before enabling."
    context_window_tokens = 32768
    max_output_tokens     = 1024
  }
  qwen3-coder-30b = {
    model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/qwen.qwen3-coder-30b-a3b-v1:0"
    description           = "Qwen coding-focused option; review terms and pricing before enabling."
    context_window_tokens = 32768
    max_output_tokens     = 1024
  }
}
