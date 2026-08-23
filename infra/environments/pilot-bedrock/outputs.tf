output "inference_profile_arns" { value = { for alias, profile in aws_bedrock_inference_profile.model : alias => profile.arn } }
output "model_source_arns" { value = { for alias, model in var.model_catalog : alias => model.model_source_arn } }
output "opencode_models" {
  value = {
    for alias, model in var.model_catalog : alias => {
      id = aws_bedrock_inference_profile.model[alias].arn
      limit = {
        context = model.context_window_tokens
        output  = model.max_output_tokens
      }
    }
  }
}
output "budget_name" { value = aws_budgets_budget.bedrock_monthly.name }
