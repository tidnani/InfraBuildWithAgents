terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstateprod000"
    container_name       = "tfstate"
    key                  = "environments/prod/terraform.tfstate"
    use_oidc             = true
  }
}
