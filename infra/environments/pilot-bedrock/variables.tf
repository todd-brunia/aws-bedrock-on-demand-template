variable "aws_account_id" { type = string }
variable "aws_region" {
  type    = string
  default = "us-east-1"
  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "The pilot template is intentionally pinned to us-east-1."
  }
}
variable "budget_notification_email" {
  type      = string
  sensitive = true
}
variable "monthly_budget_usd" {
  type    = number
  default = 20
}
variable "model_catalog" {
  description = "Approved aliases, direct foundation-model ARNs or system inference-profile IDs, and OpenCode limits. Add a model only after the preflight runbook succeeds."
  type = map(object({
    model_source_arn            = optional(string)
    system_inference_profile_id = optional(string)
    description                 = string
    context_window_tokens       = number
    max_output_tokens           = number
  }))
  default = {
    nova-lite = {
      model_source_arn      = "arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-lite-v1:0"
      description           = "Low-cost default text model."
      context_window_tokens = 300000
      max_output_tokens     = 5000
    }
  }
  validation {
    condition     = length(var.model_catalog) > 0
    error_message = "At least one approved model alias is required."
  }
  validation {
    condition = alltrue([
      for model in values(var.model_catalog) :
      (model.model_source_arn != null) != (model.system_inference_profile_id != null)
    ])
    error_message = "Each model catalog entry must set exactly one of model_source_arn or system_inference_profile_id."
  }
}

locals {
  tags = { Project = "aws-bedrock-on-demand", Environment = "pilot", ManagedBy = "terraform" }
  model_source_arns = {
    for alias, model in var.model_catalog : alias => model.model_source_arn != null ? model.model_source_arn : "arn:aws:bedrock:${var.aws_region}:${var.aws_account_id}:inference-profile/${model.system_inference_profile_id}"
  }
}
