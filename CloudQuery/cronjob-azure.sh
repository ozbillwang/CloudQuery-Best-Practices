#!/usr/bin/env bash

# make sure you have assigned "reader" role and "key vault secrets user" on the virtual machine you run the command 

vaultName="cloudquery-dev"
secretName="cloudquery-connection-string"

pushd ~/CloudQuery-Configuration/CloudQuery

# get PG_CONNECTION_STRING
az login --identity
az account set -s <sbuscription_id>
az account show

export PG_CONNECTION_STRING=$( az keyvault secret show --vault-name ${vaultName} --name ${secretName} --query value -o tsv )

# sync 
cloudquery sync ./cloudquery-config-azure

# keep sizing the log file
tail -n 10000 cloudquery.log > /tmp/cloudquery.log
mv /tmp/cloudquery.log cloudquery.log

popd

# update policies
pushd ~/cloudquery/plugins/source/azure/policies
psql "${PG_CONNECTION_STRING}" -f policy.sql
