resource "aws_bedrock_inference_profile" "model" {
  for_each    = var.model_catalog
  name        = "bedrock-on-demand-pilot-${each.key}"
  description = each.value.description
  model_source { copy_from = local.model_source_arns[each.key] }
  tags = merge(local.tags, { ModelAlias = each.key })
}

resource "aws_budgets_budget" "bedrock_monthly" {
  name         = "bedrock-on-demand-pilot-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["Amazon Bedrock"]
  }

  dynamic "notification" {
    for_each = toset([50, 80, 100])
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = [var.budget_notification_email]
    }
  }
  dynamic "notification" {
    for_each = toset([50, 80, 100])
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "FORECASTED"
      subscriber_email_addresses = [var.budget_notification_email]
    }
  }
}
