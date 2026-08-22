variable "aws_account_id" { type = string }
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "state_bucket_name" { type = string }
variable "trusted_workload_role_arns" {
  type        = set(string)
  description = "Existing, approved roles that may assume the Bedrock runtime role."
  validation {
    condition     = length(var.trusted_workload_role_arns) > 0
    error_message = "At least one workload role ARN is required."
  }
}
locals { tags = { Project = "aws-bedrock-on-demand", Environment = "pilot", ManagedBy = "terraform" } }
