# This file is safe to commit. Add exact, preflight-verified source ARNs here in
# a reviewed pull request when enabling a new model alias.
model_catalog = {
  nova-lite = {
    model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-lite-v1:0"
    description           = "Low-cost default text model."
    context_window_tokens = 300000
    max_output_tokens     = 5000
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
