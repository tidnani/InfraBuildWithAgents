project_name       = "mcritic"
primary_location   = "eastus2"
secondary_location = "westus3"
node_version       = "20-lts"

alert_email_receivers = [
  # {
  #   name          = "Platform Team"
  #   email_address = "platform-team@example.com"
  # }
]

tags = {
  CostCenter  = "production"
  Owner       = "platform-team"
  Criticality = "Mission-Critical"
}
