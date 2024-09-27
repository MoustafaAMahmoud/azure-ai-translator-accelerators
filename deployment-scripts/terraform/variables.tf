# Variables
variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

# Random string
resource "random_string" "unique" {
  length  = 4
  special = false
  upper   = false
}

# Variables
variable "prefix" {
  default = "tf-"
}

variable "name" {
  default = "ai-translator"
}
## This could be replaced with terraform workspaces
variable "environment" {
  default = "dev"
}

variable "resource_group_name" {
  default = "accelerator-rg"
}

variable "location" {
  default = "uksouth"
}

variable "storage_account_name" {
  default = "azaitranslator"
}

variable "app_service_plan_name" {
  default = "func-plan"
}

variable "function_app_name_upload" {
  default = "upload-func"
}

variable "function_app_name_translate" {
  default = "translate-func"
}

variable "function_app_name_watermark" {
  default = "watermark-func"
}

variable "storage_container_name" {
  default = "documents"
}

variable "translation_sku" {
  default = "S1"
}

variable "log_analytics_sku" {
  default = "PerGB2018"
}

variable "postgres_db_name" {
  default = "translateservice"
}

variable "postgres_administrator_login" {
  default = "citus"
}

variable "translation_service_name" {
  default = "ai-translator"
}

variable "custom_domain" {
  default = "ai-translator"
}

variable "openai_service_name" {
  default = "az-openai-service"
}
variable "public_network_access_enabled" {
  default = true
}

variable "openai_sku" {
  default = "S0"
}

variable "openai_location" {
    default = "eastus"
}

variable "chat_completions_deployment_name" {
  default = "az-chat"
}

variable "static_web_app_name" {
  default = "static-webapp"
}

variable "static_sites_region" {
  default = "westeurope"
}

variable "apim_name" {
  default = "apim"
}

variable "api_name" {
  default = "translation-service-api"
}

variable "api_path" {
  default = "translation-service"
}

variable "publisher_email" {
  default = "your-email@example.com"
}

variable "publisher_name" {
  default = "Your Company Name"
}

variable "key_vault_name" {
  default = "kv"
}
variable "sas_start_date" {
  default = "2024-08-08"
}
variable "sas_expiry_date" {
  default = "2025-12-31"
}

variable "function_app_insights_name" {
  type    = string
  default = "appinsights"
}
variable "function_service_plan_name" {
  type    = string
  default = "sp"
}

variable "upload_function_zip_path" {
  type    = string
  default = "./upload_func.zip"
}


variable "log_analytics_workspace_name" {
  description = "Specifies the name of the log analytics workspace"
  default     = "Workspace"
  type        = string
}

variable "log_analytics_retention_days" {
  description = "Specifies the number of days of the retention policy"
  type        = number
  default     = 30
}

variable "openai_deployments" {
  description = "(Optional) Specifies the deployments of the Azure OpenAI Service"
  type = list(object({
    name = string
    model = object({
      format  = string
      name    = string
      version = string
    })
    scale = object({
      capacity = number
      type     = string
    })
    rai_policy_name = string
  }))
  default = [
    {
      name = "dev"
      model = {
        format  = "OpenAI"
        name    = "gpt-4o"
        version = "2024-05-13"
      }
      scale = {
        capacity = 2
        type     = "GlobalStandard"
      }
      rai_policy_name = ""
    }
  ]
}
#
# variable "github_token" {}
# variable "github_owner" {}
# variable "github_repository" {}