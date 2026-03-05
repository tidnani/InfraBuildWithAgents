# InfraBuildWithAgents

Azure AI Connect 2026 Github Coding Agent Demo

## Mission Critical Azure App Service — Terraform IaC

This repository contains Terraform modules implementing the [Mission Critical Azure App Service Architecture](https://learn.microsoft.com/en-us/azure/architecture/guide/networking/global-web-applications/mission-critical-app-service) following [Azure Well-Architected Framework (WAF)](https://learn.microsoft.com/en-us/azure/architecture/framework/) principles.

---

## Architecture Overview

```
Internet ──► Azure Front Door (Premium) ──► Web Application Firewall (WAF)
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
  App Service (Primary)   App Service (Secondary)    ← Zone-redundant, Premium v3
  eastus2                 westus3
     │                       │
  VNet Integration        VNet Integration
     │                       │
  Private Endpoint        Private Endpoint
     │
  Key Vault ──► Private Endpoint ──► Private DNS Zone
     │
  Log Analytics Workspace + Application Insights + Alerts
```

### Key Components

| Module | Azure Resource | Purpose |
|--------|---------------|---------|
| `resource_group` | Azure Resource Group | Container for all resources |
| `networking` | VNet, Subnets, NSGs, Private DNS Zones | Network isolation & private connectivity |
| `app_service` | App Service Plan + Linux Web App + Autoscale | Application hosting (zone-redundant) |
| `front_door` | Azure Front Door Premium + WAF Policy | Global load balancing, DDoS, WAF |
| `key_vault` | Azure Key Vault + Private Endpoint + RBAC | Secrets management |
| `monitoring` | Log Analytics + App Insights + Alerts + Action Group | Observability & alerting |

---

## Repository Structure

```
.
├── modules/
│   ├── resource_group/     # Azure Resource Group
│   ├── networking/         # VNet, Subnets, NSGs, Private DNS Zones
│   ├── app_service/        # App Service Plan + Web App + Autoscale + Private Endpoint
│   ├── front_door/         # Azure Front Door Premium + WAF
│   ├── key_vault/          # Key Vault + Private Endpoint + RBAC
│   └── monitoring/         # Log Analytics + App Insights + Alerts
├── environments/
│   ├── dev/                # Development environment (single region, P1v3)
│   └── prod/               # Production environment (multi-region, zone-redundant)
├── tests/                  # Terratest Go integration tests
└── .github/
    └── workflows/
        ├── terraform-deploy.yml   # CI/CD pipeline (plan + apply + destroy)
        └── terraform-test.yml     # Unit + integration test pipeline
```

---

## Azure WAF Principles Applied

### Reliability
- **Zone-redundant** App Service Plans (`P1v3` with `zone_balancing_enabled = true`) in production
- **Multi-region** deployment (primary + secondary) behind Azure Front Door
- **Health probes** on Front Door origin groups with automatic failover
- **Autoscaling** configured for all App Service Plans
- **Soft delete & purge protection** on Key Vault

### Security
- **Private endpoints** for App Service and Key Vault (no public internet access)
- **VNet integration** for App Service egress
- **WAF Policy** (Prevention mode in prod, Detection in dev) with OWASP rules + Bot Manager
- **RBAC-only** Key Vault authorization (no legacy access policies)
- **HTTPS-only** Web Apps with TLS 1.2 minimum
- **OIDC-based** CI/CD authentication (no stored credentials)
- **NSGs** restricting inbound traffic to `AzureFrontDoor.Backend` service tag only

### Operational Excellence
- **Diagnostic settings** on all resources → Log Analytics Workspace
- **Application Insights** with workspace-based telemetry
- **Metric alerts** for CPU, memory, HTTP 5xx errors, response time, Front Door origin health
- **Autoscale** with scale-out on CPU > 70% and scale-in on CPU < 30%
- **Sticky app settings** for Application Insights configuration

### Performance Efficiency
- **CDN caching** via Azure Front Door with content type compression
- **Autoscaling** to handle traffic spikes
- **Zone balancing** for even distribution across availability zones

### Cost Optimization
- Dev environment uses non-zone-redundant single-instance P1v3
- Production uses zone-redundant P1v3 with autoscaling (3–20 instances)
- Log retention tuned per environment (30 days dev, 90 days prod)

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.9
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) or OIDC-based service principal
- Azure subscription with Contributor + User Access Administrator roles
- A Terraform remote state storage account (Azure Blob Storage)

---

## Getting Started

### 1. Configure Azure Authentication

This project uses **OIDC (Workload Identity Federation)** for GitHub Actions. Configure the following repository secrets:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Application (client) ID of the service principal |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Default Azure subscription ID |
| `DEV_AZURE_SUBSCRIPTION_ID` | (Optional) Dev-specific subscription |
| `PROD_AZURE_SUBSCRIPTION_ID` | (Optional) Prod-specific subscription |

### 2. Create Remote State Storage

```bash
# Create state storage for dev
az group create --name tfstate-rg --location eastus2
az storage account create --name tfstatedev --resource-group tfstate-rg --sku Standard_LRS
az storage container create --name tfstate --account-name tfstatedev

# Create state storage for prod
az storage account create --name tfstateprod --resource-group tfstate-rg --sku Standard_LRS
az storage container create --name tfstate --account-name tfstateprod
```

### 3. Local Development

```bash
# Authenticate
az login
export ARM_SUBSCRIPTION_ID="<your-subscription-id>"

# Deploy dev environment
cd environments/dev
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### 4. Customize Variables

Edit `environments/dev/terraform.tfvars` or `environments/prod/terraform.tfvars`:

```hcl
project_name     = "myapp"
primary_location = "eastus2"
node_version     = "20-lts"

alert_email_receivers = [
  {
    name          = "Platform Team"
    email_address = "platform@example.com"
  }
]
```

---

## Using a Module Independently

```hcl
module "networking" {
  source = "git::https://github.com/tidnani/InfraBuildWithAgents.git//modules/networking?ref=main"

  vnet_name           = "my-vnet"
  location            = "eastus2"
  resource_group_name = "my-rg"
  vnet_address_space  = ["10.0.0.0/16"]
  tags = {
    Environment = "dev"
  }
}
```

---

## Running Tests

```bash
# Unit tests (no Azure required)
terraform fmt -check -recursive
for module in modules/*/; do
  (cd "$module" && terraform init -backend=false && terraform validate)
done

# Integration tests (requires Azure subscription)
cd tests
go mod download
go test -v -timeout 60m ./...

# Test a specific module
go test -v -timeout 30m -run TestResourceGroupModule ./...
```

---

## CI/CD Workflows

### `terraform-deploy.yml`
- **On PR**: validates all modules (fmt + validate) and plans dev environment
- **On merge to main**: applies dev environment automatically
- **Manual dispatch**: plan/apply/destroy any environment with required approvals

### `terraform-test.yml`
- **Unit tests**: format check + `terraform validate` for all modules (no Azure required)
- **Integration tests**: full Terratest suite against dev subscription (on merge to main or manual trigger)

---

## Module Reference

### `modules/resource_group`

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `name` | string | required | Resource group name (1–90 chars) |
| `location` | string | required | Azure region |
| `tags` | map(string) | `{}` | Tags to apply |

### `modules/networking`

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `vnet_name` | string | required | VNet name |
| `location` | string | required | Azure region |
| `resource_group_name` | string | required | Resource group name |
| `vnet_address_space` | list(string) | `["10.0.0.0/16"]` | VNet CIDR blocks |
| `app_service_subnet_prefixes` | list(string) | `["10.0.1.0/24"]` | App Service subnet CIDRs |
| `private_endpoint_subnet_prefixes` | list(string) | `["10.0.2.0/24"]` | Private endpoint subnet CIDRs |

### `modules/app_service`

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `app_service_plan_name` | string | required | App Service Plan name |
| `web_app_name` | string | required | Web App name |
| `sku_name` | string | `"P1v3"` | Must be Premium v3 tier |
| `zone_balancing_enabled` | bool | `true` | Enable zone redundancy |
| `worker_count` | number | `3` | Minimum 3 for zone redundancy |

### `modules/front_door`

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `front_door_name` | string | required | Front Door profile name |
| `sku_name` | string | `"Premium_AzureFrontDoor"` | Premium required for private link |
| `waf_mode` | string | `"Prevention"` | Use Detection in dev |
| `origins` | map(object) | required | Origin configurations |

### `modules/key_vault`

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `name` | string | required | Key Vault name (3–24 chars) |
| `soft_delete_retention_days` | number | `90` | 7–90 days |
| `web_app_principal_ids` | list(string) | `[]` | Managed identity principals for Key Vault Secrets User |

### `modules/monitoring`

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `log_analytics_workspace_name` | string | required | Log Analytics workspace name |
| `app_insights_name` | string | required | Application Insights name |
| `log_retention_days` | number | `90` | Log retention (30/60/90/120/180/270/365/550/730) |
| `alert_email_receivers` | list(object) | `[]` | Email addresses for alerts |
