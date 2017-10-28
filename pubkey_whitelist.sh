#!/bin/bash

cert=$1

a=$(az keyvault certificate show --vault-name $cert --name whinn-infra-dev | jq .cer)

echo $a >> $cert.cer
