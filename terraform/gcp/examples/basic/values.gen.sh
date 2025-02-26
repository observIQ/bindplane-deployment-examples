#!/bin/bash

set -e

terraform refresh

database_host=$(terraform output -json database_host | jq -r '.[0].ip_address')
database_name=$(terraform output -raw database_name)

if [ -z "${database_host}" ]; then
  echo "database_host is required"
  exit 1
fi

if [ -z "${database_name}" ]; then
  echo "database_name is required"
  exit 1
fi

# heredoc for values.yaml
cat <<EOF > values.yaml
config:
  secret: bindplane
  licenseUseSecret: true
  accept_eula: true
backend:
  type: postgres
  postgres:
    host: ${database_host}
    port: 5432
    database: ${database_name}
    credentialSecret:
      name: bindplane-db
      usernameKey: username
      passwordKey: password
    maxConnections: 80
resources:
  requests:
    cpu: 1000m
    memory: 1Gi
  limits:
    memory: 1Gi
prometheus:
  resources:
    requests:
      cpu: 1000m
      memory: 1Gi
    limits:
      memory: 1Gi
EOF
