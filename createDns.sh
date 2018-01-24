#!/usr/bin/env bash


domain=$1
rg=$2
uri=$3
ilbIp=$4

echo "-----------------------"

echo $domain
echo $rg
echo $uri
pwd
echo "-----------------------"
#get ip of consul
consul=$(az vmss nic list --resource-group $rg --vmss-name consul-server --query "[0].ipConfigurations[0].privateIpAddress")

consul=$(echo "$consul" | sed -e 's/^"//' -e 's/"$//')

echo $consul

echo "-----------------------"


# Create 2 consul entries (service + scm)
sed -i -e "s/serviceId/$domain/g" "${uri}/consul.json"
sed -i -e "s/serviceName/$domain/g" "${uri}/consul.json"
sed -i -e "s/aseIlb/$ilbIp/g" "${uri}/consul.json"

curl -T "${uri}/consul.json" "http://${consul}:8500/v1/agent/service/register"
