# Uncomment and configure the backend block to use Azure Storage for remote state.
# Create the storage account and container before enabling this backend.
#
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state-prod"
#     storage_account_name = "sttfstateprod001"
#     container_name       = "tfstate"
#     key                  = "prod.terraform.tfstate"
#     use_oidc             = true
#   }
# }
#
# To initialize with backend:
# terraform init \
#   -backend-config="resource_group_name=rg-terraform-state-prod" \
#   -backend-config="storage_account_name=sttfstateprod001" \
#   -backend-config="container_name=tfstate" \
#   -backend-config="key=prod.terraform.tfstate"
