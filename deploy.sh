#!/usr/bin/env bash

if az group exists --name nomad-rg; then
  az group delete --name nomad-rg
fi

az group create --name nomad-rg --location westeurope

az vmss create \
  --resource-group nomad-rg \
  --name nomad-server-vmss \
  --image UbuntuLTS \
  --upgrade-policy-mode automatic \
  --admin-username azureuser \
  --generate-ssh-keys \
  --lb nomad-lb \
  --backend-pool-name nomad-bp \
  --public-ip-address nomad-public-ip \
  --vnet-name nomad-vnet \
  --output json \
  --verbose

az network lb rule create \
  --resource-group nomad-rg \
  --name nomad-lb-rule-https \
  --lb-name nomad-lb \
  --backend-pool-name nomad-bp \
  --backend-port 443 \
  --frontend-ip-name nomad-public-ip \
  --frontend-port 443 \
  --protocol tcp

#NIC_ID=$(az vm show -n nomad-server-vm -g nomad-rg \
#  --query 'networkProfile.networkInterfaces[].id' \
#  -o tsv)