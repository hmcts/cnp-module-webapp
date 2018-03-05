#!/usr/bin/env bash


domain=$1
rg=$2
uri=$3
ilbIp=$4
subscription=$5

echo "-----------------------"

echo $domain
echo $rg
echo $uri
pwd
echo "-----------------------"
#get ip of consul
consul=$(env AZURE_CONFIG_DIR=/opt/jenkins/.azure-$subscription az vmss nic list --resource-group $rg --vmss-name consul-server --query "[0].ipConfigurations[0].privateIpAddress")

consul=$(echo "$consul" | sed -e 's/^"//' -e 's/"$//')

echo $consul

echo "-----------------------"

register_dns () {
  domain=$1
  uri=$2
  ilbIp=$3

  tmp_dir=$(mktemp -d)
  cp "${uri}/consul.json" "$tmp_dir"
  sed -i -e "s/serviceId/$domain/g" "$tmp_dir/consul.json"
  sed -i -e "s/serviceName/$domain/g" "$tmp_dir/consul.json"
  sed -i -e "s/aseIlb/$ilbIp/g" "$tmp_dir/consul.json"

  curl -T "$tmp_dir/consul.json" "http://${consul}:8500/v1/agent/service/register"
}

# Create 2 consul entries (service + scm)

register_dns $domain $uri $ilbIp
