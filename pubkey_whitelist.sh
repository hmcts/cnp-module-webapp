#!/bin/bash

cert=$1
gw=$2
rg=$3

a=$(az keyvault certificate show --vault-name $cert --name whinn-infra-dev | jq .cer | sed 's/^"\(.*\)"$/\1/')

echo $a >> $cert.cer

az network application-gateway auth-cert create --cert-file ./$cert.cer --gateway-name $gw --name $cert-app --resource-group $rg
