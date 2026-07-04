variable "platform" {
  description = "SQL-focused platform configuration, normally supplied from platform.auto.tfvars."
  type        = any

  default = {
    tags = {
      scope   = "platform"
      project = "azure-aks-platform-blueprint"
      purpose = "portfolio-demo"
    }

    resource_groups = {
      platform = {
        name     = "rg-aks-platform"
        location = "Southeast Asia"
        tags     = {}
      }
    }

    azure_sql_servers = {
      platform = {
        name                          = "sql-aks-platform"
        resource_group_key            = "platform"
        minimum_tls_version           = "1.2"
        public_network_access_enabled = true
        azuread_administrator = {
          use_current_client          = true
          login_username              = "current-client"
          azuread_authentication_only = true
        }
        elastic_pools = {
          app = {
            name        = "sqlep-platform-app"
            max_size_gb = 4.8828125
            sku = {
              name     = "BasicPool"
              tier     = "Basic"
              capacity = 50
            }
            per_database_settings = {
              min_capacity = 0
              max_capacity = 5
            }
            tags = {
              workload = "application"
            }
          }
        }
        databases = {
          app = {
            name                 = "sqldb-platform-app"
            elastic_pool_key     = "app"
            max_size_gb          = 2
            storage_account_type = "Local"
            tags = {
              workload = "application"
            }
          }
        }
        tags = {
          workload = "database"
        }
      }
    }

    managed_identities = {
      app01_runtime = {
        name               = "id-app01-runtime"
        resource_group_key = "platform"
        tags = {
          workload = "app01"
          purpose  = "runtime"
        }
      }
      app01_migration = {
        name               = "id-app01-migration"
        resource_group_key = "platform"
        tags = {
          workload = "app01"
          purpose  = "migration"
        }
      }
      app01_reporting = {
        name               = "id-app01-reporting"
        resource_group_key = "platform"
        tags = {
          workload = "app01"
          purpose  = "reporting"
        }
      }
      github_actions = {
        name               = "id-github-actions-aks-platform"
        resource_group_key = "platform"
        acr_key            = "platform"
        federated_identity_credentials = {
          main = {
            name     = "github-actions-main"
            audience = ["api://AzureADTokenExchange"]
            issuer   = "https://token.actions.githubusercontent.com"
            subject  = "repo:Legiang98/azure-aks-platform-blueprint:ref:refs/heads/main"
          }
        }
        tags = {
          workload = "github-actions"
          purpose  = "ci-cd-oidc"
        }
      }
    }

    container_registries = {
      platform = {
        # Must be globally unique before apply.
        name                          = "craksplatformdemo001"
        resource_group_key            = "platform"
        sku                           = "Basic"
        admin_enabled                 = false
        public_network_access_enabled = true
        tags = {
          workload = "artifacts"
          purpose  = "container-images-and-helm-oci"
        }
      }
    }
  }
}
