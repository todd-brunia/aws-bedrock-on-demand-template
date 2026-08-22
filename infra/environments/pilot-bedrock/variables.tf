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
  description = "Approved aliases and exact Bedrock model source ARNs. Add a model only after the preflight runbook succeeds."
  type        = map(object({ model_source_arn = string, description = string }))
  default = {
    nova-lite = {
      model_source_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-lite-v1:0"
      description      = "Low-cost default text model."
    }
  }
  validation {
    condition     = length(var.model_catalog) > 0
    error_message = "At least one approved model alias is required."
  }
}

locals { tags = { Project = "aws-bedrock-on-demand", Environment = "pilot", ManagedBy = "terraform" } }
