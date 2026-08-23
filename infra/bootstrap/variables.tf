variable "aws_account_id" { type = string }
variable "aws_region" {
  type    = string
  default = "us-east-1"
  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "Bootstrap is pinned to us-east-1 because the pilot remote-state backends are pinned to us-east-1."
  }
}
variable "state_bucket_name" { type = string }
variable "github_repository" { type = string }
variable "pilot_environment_name" {
  type    = string
  default = "pilot"
}
variable "github_oidc_provider_arn" {
  type        = string
  default     = null
  nullable    = true
  description = "Existing account-level GitHub OIDC provider ARN. Leave null only when this bootstrap owns the provider."
}

locals {
  tags = { Project = "aws-bedrock-on-demand", Environment = "bootstrap", ManagedBy = "terraform" }
}
