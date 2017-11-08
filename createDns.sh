#!/usr/bin/env bash


domain=$1
rg=$2

#get ip of consul
consul=$(az vmss nic list --resource-group $rg --vmss-name consul-server --query "[0].ipConfigurations[0].privateIpAddress")

# Create 2 consul entries (service + scm)
sed -i -e "s/serviceId/$domain/g" consul.json
sed -i -e "s/serviceName/$domain/g" consul.json
sed -i -e "s/aseIlb/$consul/g" consul.json

curl --request PUT --data @consul.json http://$consul:8500/v1/agent/service/register

sed -i -e "s/$domain/scm/g" consul.json
sed -i -e "s/\[\]/\[$domain\]/g" consul.json

curl --request PUT --data @consul.json http://$consul:8500/v1/agent/service/register
