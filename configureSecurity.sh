#!/bin/bash
appName=$1
resourceGroup=$2
tenantId="https://sts.windows.net/$3"
clientId=$4
clientSecret=$5
loginAction=LoginWithAzureActiveDirectory

if [ ! -z "$tenantId" ] && [ ! -z "$clientId" ] && [ ! -z "$clientSecret" ];
then
	az webapp auth update --name $appName --resource-group $resourceGroup --aad-token-issuer-url $tenantId --aad-client-id $clientId --action $loginAction --aad-client-secret $clientSecret --enabled true
elif [ ! -z "$tenantId" ] && [ ! -z "$clientId" ];
then
	az webapp auth update --name $appName --resource-group $resourceGroup --aad-token-issuer-url $tenantId --aad-client-id $clientId --action $loginAction --enabled true
else
	az webapp auth update --name $appName --resource-group $resourceGroup --enabled false
fi
