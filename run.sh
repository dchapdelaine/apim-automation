#!/bin/bash 

rgName="apim"
vnetName="apimvnet"
subnetName="apimsubnet"
location="Canada East"


# az login
# az group delete -n $rgName

az group create --name $rgName --location $location
az network vnet create -g $rgName --subnet-name $subnetName -n $vnetName
# xargs strips double quotes
subnetId=$(az network vnet subnet show -g $rgName -n $subnetName --vnet-name $vnetName --query "id" | xargs)

az group deployment create \
  --name deployment \
  --resource-group $rgName \
  --template-file azuredeploy.json \
  --parameters publisherEmail=email@example.com \
  --parameters publisherName=templateTest \
  --parameters subnetId=$subnetId

  token=$(az account get-access-token --query accessToken | xargs)
  curl -X GET -H "Authorization: Bearer $token" -H "Content-Type: application/json" https://management.azure.com/subscriptions/[SUBSCRIPTION_ID]/providers/Microsoft.Web/sites?api-version=2016-08-01

  GET https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ApiManagement/service/{serviceName}/tenant/access/git?api-version=2018-06-01-preview