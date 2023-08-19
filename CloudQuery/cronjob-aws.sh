#!/usr/bin/env bash

pushd ~/CloudQuery-Configuration/CloudQuery

export PG_CONNECTION_STRING=$(aws ssm get-parameter --name cloudquery-pg-connection-string --with-decryption --query 'Parameter.Value' --output text)

# sync 
cloudquery sync ./cloudquery-config-aws

# update policies
pushd ~/cloudquery/plugins/source/aws/policies
psql "${PG_CONNECTION_STRING}" -f policy.sql
popd

# keep sizing the log file
tail -n 10000 cloudquery.log > /tmp/cloudquery.log
mv /tmp/cloudquery.log cloudquery.log

popd
