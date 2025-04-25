#!/bin/bash

set -e

terraform refresh

database_host=$(terraform output -json database_host | jq -r '.[0].ip_address')
database_name=$(terraform output -raw database_name)
bindplane_pubsub_project_id=$(terraform output -raw bindplane_pubsub_project_id )
bindplane_pubsub_topic=$(terraform output -raw bindplane_pubsub_topic)
bindplane_iam_service_account_email=$(terraform output -raw bindplane_iam_service_account_email)
remote_url=$(terraform output -raw bindplane_remote_url)

if [ -z "${database_host}" ]; then
  echo "database_host is required"
  exit 1
fi

if [ -z "${database_name}" ]; then
  echo "database_name is required"
  exit 1
fi

if [ -z "${bindplane_pubsub_project_id}" ]; then
  echo "bindplane_pubsub_project_id is required"
  exit 1
fi

if [ -z "${bindplane_pubsub_topic}" ]; then
  echo "bindplane_pubsub_topic is required"
  exit 1
fi

if [ -z "${bindplane_iam_service_account_email}" ]; then
  echo "bindplane_iam_service_account_email is required"
  exit 1
fi

if [ -z "${remote_url}" ]; then
  echo "remote_url is required"
  exit 1
fi


# heredoc for values.yaml
cat <<EOF > values.yaml
replicas: 3

config:
  secret: bindplane
  licenseUseSecret: true
  accept_eula: true
  server_url: ${remote_url}
eventbus:
  type: pubsub
  pubsub:
    projectid: ${bindplane_pubsub_project_id}
    topic: ${bindplane_pubsub_topic}
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
    maxConnections: 50
resources:
  requests:
    cpu: 2000m
    memory: 4Gi
  limits:
    memory: 4Gi
prometheus:
  resources:
    requests:
      cpu: 2000m
      memory: 4Gi
    limits:
      memory: 4Gi
transform_agent:
  replicas: 2
serviceAccount:
  annotations:
    iam.gke.io/gcp-service-account: ${bindplane_iam_service_account_email}
service:
  annotations:
    cloud.google.com/backend-config: '{"default": "bindplane-backend-config"}'
EOF
