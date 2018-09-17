#!/bin/bash 

# az login
rgName="apim"

az group create --name $(rgName) --location "Canada East"
az network vnet create -g $(rgName) --subnet-name apimsubnet -n apimvnet
az group deployment create \
  --name deployment \
  --resource-group $(rgName) \
  --template-file azuredeploy.json \
  --parameters storageAccountType=Standard_GRS