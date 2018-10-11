#!/bin/bash 

# BEGIN : Variables to define here
rgName="apimautomation"
apimName="dchapimautomation"
vnetName="apimvnet"
subnetName="apimsubnet"
location="Canada East"
apimLocalGit="../apim-automation-gitsync"
# END

# az login (you can use a service principal)...

# Precreating a vnet to better match the customer use case
az group create --name $rgName --location $location
az network vnet create -g $rgName --subnet-name $subnetName -n $vnetName
subnetId=$(az network vnet subnet show -g $rgName -n $subnetName --vnet-name $vnetName --query "id" | xargs)
subId=$(az account show --query "id" | xargs)

# Deploy APIM
az group deployment create \
  --name deployment \
  --resource-group $rgName \
  --template-file azuredeploy.json \
  --parameters publisherEmail=email@example.com \
  --parameters publisherName=templateTest \
  --parameters subnetId=$subnetId \
  --parameters apiManagementServiceName=$apimName

# Get your Azure RM access token which we'll reuse with Curl.
token=$(az account get-access-token --query accessToken | xargs)
baseAPIUrl="https://management.azure.com/subscriptions/$subId/resourceGroups/$rgName/providers/Microsoft.ApiManagement/service/$apimName"
apiVersion="api-version=2018-06-01-preview"


# Get git access token
expiry=$(date -d "today + 1 day" -I)
gitTokenResponse=$(curl \
  -X POST \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d "{\"expiry\": \"$expiry\", \"keyType\": \"primary\"}" \
  $baseAPIUrl/users/git/token\?$apiVersion \
)

# URL Encode function taken from: https://gist.github.com/cdown/1163649/8a35c36fdd24b373788a7057ed483a5bcd8cd43e
_encode() {
    local _length="${#1}"
    for (( _offset = 0 ; _offset < _length ; _offset++ )); do
        _print_offset="${1:_offset:1}"
        case "${_print_offset}" in
            [a-zA-Z0-9.~_-]) printf "${_print_offset}" ;;
            ' ') printf + ;;
            *) printf '%%%X' "'${_print_offset}" ;;
        esac
    done
}

# url encode the password/token and prepare the final git url
gitPassword=$(echo -n -e $gitTokenResponse | jq -r ".value")
gitPasswordEncoded=$(_encode $gitPassword)
gitUrl="https://apim:$gitPasswordEncoded@$apimName.scm.azure-api.net"

# Assuming that we have the configuration that we want to deploy in the git repo at $apimLocalGit
# we directly push to the git url of apim (without using a remote).
pushd $apimLocalGit
git push $gitUrl master
popd

# Publish Changes from the git repo to the API Management config
gitDeployResponse=$(curl \
  -X POST \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d '{"branch": "master", "force" : "true"}' \
  $baseAPIUrl/tenant/configuration/deploy\?$apiVersion \
)

echo "All done!"