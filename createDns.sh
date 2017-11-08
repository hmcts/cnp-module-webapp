#!/usr/bin/env bash


domain=$1
rg=$2
uri=$3

echo $domain
echo $rg
echo $uri

#get ip of consul
consul=$(az vmss nic list --resource-group $rg --vmss-name consul-server --query "[0].ipConfigurations[0].privateIpAddress")

consul=$(echo "$consul" | sed -e 's/^"//' -e 's/"$//')

echo $consul

# Create 2 consul entries (service + scm)
sed -i -e "s/serviceId/$domain/g" "${uri}/consul.json"
sed -i -e "s/serviceName/$domain/g" "${uri}/consul.json"
sed -i -e "s/aseIlb/$consul/g" "${uri}/consul.json"

curl --request PUT --data "{$uri}/consul.json" "http://${consul}:8500/v1/agent/service/register"

sed -i -e "s/$domain/scm/g" "${uri}/consul.json"
sed -i -e "s/\[\]/\[$domain\]/g" "${uri}/consul.json"

curl --request PUT --data "${uri}/consul.json" "http://${consul}:8500/v1/agent/service/register"
