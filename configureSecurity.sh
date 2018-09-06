#!/bin/bash
subscription=$1
appName=$2
resourceGroup=$3
tenantId="https://sts.windows.net/$4"
clientId=$5
clientSecret=$6
loginAction=LoginWithAzureActiveDirectory

if [ ! -z "$tenantId" ] && [ ! -z "$clientId" ] && [ ! -z "$clientSecret" ];
then
	env AZURE_CONFIG_DIR=/opt/jenkins/.azure-$subscription az webapp auth update --name $appName --resource-group $resourceGroup --aad-token-issuer-url $tenantId --aad-client-id $clientId --action $loginAction --aad-client-secret $clientSecret --enabled true
elif [ ! -z "$tenantId" ] && [ ! -z "$clientId" ];
then
	env AZURE_CONFIG_DIR=/opt/jenkins/.azure-$subscription az webapp auth update --name $appName --resource-group $resourceGroup --aad-token-issuer-url $tenantId --aad-client-id $clientId --action $loginAction --enabled true
else
	env AZURE_CONFIG_DIR=/opt/jenkins/.azure-$subscription az webapp auth update --name $appName --resource-group $resourceGroup --enabled false
fi
