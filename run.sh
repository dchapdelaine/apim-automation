#!/bin/bash 

rgName="apim"
apimName="apiserviceo5xmu3coaq5m2"
vnetName="apimvnet"
subnetName="apimsubnet"
location="Canada East"


# az login
# az group delete -n $rgName

az group create --name $rgName --location $location
az network vnet create -g $rgName --subnet-name $subnetName -n $vnetName
# xargs strips double quotes
subnetId=$(az network vnet subnet show -g $rgName -n $subnetName --vnet-name $vnetName --query "id" | xargs)
subId=$(az account show --query "id" | xargs)

az group deployment create \
  --name deployment \
  --resource-group $rgName \
  --template-file azuredeploy.json \
  --parameters publisherEmail=email@example.com \
  --parameters publisherName=templateTest \
  --parameters subnetId=$subnetId \
  --parameters apiManagementServiceName=$apimName

  token=$(az account get-access-token --query accessToken | xargs)
  curl -X GET -H "Authorization: Bearer $token" -H "Content-Type: application/json" https://management.azure.com/subscriptions/$subId/resourceGroups/$rgName/providers/Microsoft.ApiManagement/service/$apimName/tenant/access/git -d "api-version=2018-06-01-preview" 
