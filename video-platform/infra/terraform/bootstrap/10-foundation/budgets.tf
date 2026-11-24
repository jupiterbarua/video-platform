# One budget for the whole account, one per environment (filtered by the Environment tag).
locals {
  budgets = {
    account = null
    dev     = "user:Environment$dev"
    staging = "user:Environment$staging"
    prod    = "user:Environment$prod"
  }
}

resource "aws_budgets_budget" "this" {
  for_each = local.budgets

  name         = "${var.name_prefix}-${each.key}-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.budget_limits_usd[each.key])
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  dynamic "cost_filter" {
    for_each = each.value == null ? [] : [each.value]

    content {
      name   = "TagKeyValue"
      values = [cost_filter.value]
    }
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alert_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.budget_alert_emails
  }
}

# Per-environment budgets only see costs once the Environment tag is active for billing.
resource "aws_ce_cost_allocation_tag" "environment" {
  count = var.activate_cost_allocation_tag ? 1 : 0

  tag_key = "Environment"
  status  = "Active"
}
