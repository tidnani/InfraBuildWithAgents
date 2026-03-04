terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstatedev000"
    container_name       = "tfstate"
    key                  = "environments/dev/terraform.tfstate"
    use_oidc             = true
  }
}
