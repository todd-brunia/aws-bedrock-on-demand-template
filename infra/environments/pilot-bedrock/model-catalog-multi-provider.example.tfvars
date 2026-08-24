# Opt-in starter catalog for OpenCode chat. Before using any entry, confirm the
# current AWS pricing, regional availability, provider terms, and model access
# in the workload account. Copy selected entries—not necessarily all of them—
# into model-catalog.auto.tfvars in a reviewed pull request.
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
  qwen3-coder-next = {
    model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/qwen.qwen3-coder-next"
    description           = "Qwen coding model for planning and software-engineering evaluation."
    context_window_tokens = 131072
    max_output_tokens     = 8192
  }
  minimax-m2-5 = {
    model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/minimax.minimax-m2.5"
    description           = "MiniMax agent-native model for planning-workflow evaluation."
    context_window_tokens = 131072
    max_output_tokens     = 8192
  }
  devstral-2-123b = {
    model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/mistral.devstral-2-123b"
    description           = "Mistral coding model for software-engineering planning evaluation."
    context_window_tokens = 131072
    max_output_tokens     = 8192
  }
  kimi-k2-5 = {
    model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/moonshotai.kimi-k2.5"
    description           = "Moonshot AI planning and reasoning model for comparative evaluation."
    context_window_tokens = 131072
    max_output_tokens     = 8192
  }
  claude-sonnet-4-5 = {
    system_inference_profile_id = "us.anthropic.claude-sonnet-4-5-20250929-v1:0"
    description                 = "Anthropic planning and coding model through the US system inference profile."
    context_window_tokens       = 131072
    max_output_tokens           = 8192
  }
  claude-sonnet-4-6 = {
    system_inference_profile_id = "us.anthropic.claude-sonnet-4-6"
    description                 = "Anthropic planning and coding model through the US system inference profile."
    context_window_tokens       = 131072
    max_output_tokens           = 8192
  }
}
