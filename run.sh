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