# Automation for Azure API Management (APIM)
This example is destined to those who do not want to leverage the [Azure Powershell cmdlets for APIM](https://docs.microsoft.com/en-us/powershell/module/azurerm.apimanagement) and would rather stick to Azure CLI, bash and curl. It would be useful when you already have a configuration for APIM in a local git repository that you want to automatically deploy to APIM.

## Prerequisites

1. Bash
2. Curl
3. [jq](https://stedolan.github.io/jq/download/)
4. [Azure-CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## How it works
Using Azure CLI, this script will create a Resource Group and a VNET. It will then deploy an APIM instance using an ARM template since APIM is not supported in Azure CLI. Once this is done, the script will use the token from Azure CLI to then make API calls to the Azure Resource Manager API with Curl.
Calls will be made to generate a temporary password to access the internal git repository of APIM and then push a local APIM configuration to your APIM instance. Finally using the REST APIs we will have APIM update its internal configuration based on it's git repo.
