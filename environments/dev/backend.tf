# Uncomment and configure the backend block to use Azure Storage for remote state.
# Create the storage account and container before enabling this backend.
#
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state-dev"
#     storage_account_name = "sttfstatedev001"
#     container_name       = "tfstate"
#     key                  = "dev.terraform.tfstate"
#     use_oidc             = true
#   }
# }
#
# To initialize with backend:
# terraform init \
#   -backend-config="resource_group_name=rg-terraform-state-dev" \
#   -backend-config="storage_account_name=sttfstatedev001" \
#   -backend-config="container_name=tfstate" \
#   -backend-config="key=dev.terraform.tfstate"
