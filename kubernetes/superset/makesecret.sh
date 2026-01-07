#!/bin/bash

environment=$1;shift

if ! [[ "$environment" =~ ^(prod|stage)$ ]]; then
  echo "Usage: $0 <prod|stage>"
  exit 1
fi

echo "Generating superset secrets for ${environment}."

set -euo pipefail

# this script will
# - decrypt the sops encrypted local secrets
# - use them to render JUST the "superset secret config" K8s secret YAML
#   note you MUST add the superset helm repo locally for this to work
#   https://superset.apache.org/docs/installation/kubernetes/#running
# - convert it to JSON
# - store it in Google Secret Manager

# This is because the External Secrets operator wants JSON, not YAML for structured data

# to see the current secret in Secret Manager run:
# gcloud secrets versions access latest --secret=superset

secret_exists() {
  # evaluates true if secret exists, false otherwise
  secret_name=$1;shift
  gcloud secrets list --format=json \
  | jq -e --arg name "${secret_name}" '
      any(.[]; (.name | split("/") | last) == $name)
    ' >/dev/null
}

upsert_secret() {
  # given a secret name in google secret manager
  # - check if it exists
  # - if it doesn't exist, create it
  # - if it exists, fetch current value
  # - if current value doesn't match new value, update it
  secret_name=$1;shift
  new_secret_data=$1;shift

  if secret_exists ${secret_name}; then
    old_secret_data=$(gcloud secrets versions access latest --secret=${secret_name})

    # if the secret in Secret Manager doesn't match what we just rendered, update SM
    if [[ $(md5sum <<< ${old_secret_data}) != $(md5sum <<< ${new_secret_data}) ]]; then
      echo "The contents of ${secret_name} have changed, pushing new version to Secret Manager."
      printf '%s' "${new_secret_data}" | gcloud --project gpo-eng-${environment} secrets versions add ${secret_name} --data-file=-
    else
      echo "The contents of ${secret_name} have not changed, so we're not updating anything."
    fi

  else
    echo "Creating brand new secret ${secret_name}."
    printf '%s' "${new_secret_data}" | gcloud --project gpo-eng-${environment} secrets create ${secret_name} --data-file=-
  fi
}

# Superset uses three K8s secrets

######## name: superset-config

superset_config_json=$(sops exec-env "secrets.${environment}.env" '
    helmfile --log-level warn template \
      --file "${environment}/helmfile.yaml" \
      --show-only templates/secret-superset-config.yaml \
      --set init.adminUser.password="${superset_admin_user_pass}"' | yq -ojson | jq '.stringData'
)

echo $superset_config_json

exit

upsert_secret superset-config "${superset_config_json}"

######## name: superset-env

superset_env_json=$(sops exec-env "secrets.${environment}.env" '
    helmfile --log-level warn template \
      --file "${environment}/helmfile.yaml" \
      --show-only templates/secret-env.yaml \
      --set extraSecretEnv.SUPERSET_SECRET_KEY="${superset_secret_key}"' | yq -ojson | jq '.stringData'
)

upsert_secret superset-env "${superset_env_json}"

######## name: superset-postegresql

# TODO: https://github.com/gpo/gpo-platform-configs/issues/146
