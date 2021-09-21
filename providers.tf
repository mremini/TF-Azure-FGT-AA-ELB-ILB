provider "azurerm" {
  features {}

  # There are multiple ways to authenticate
  # Check the provider docs to determine which
  # is the best for your environment
  # Ensure the variables are declared 

  subscription_id = var.azsubscriptionid
  #client_id       = var.client_id
  #client_secret   = var.client_secret
  #tenant_id       = var.tenant_id
}

provider "fortios" {
  hostname     = var.fgttfaccess
  token        = var.fgttftoken
  insecure     = "true"

}