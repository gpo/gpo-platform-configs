#!/bin/bash

# this script will fetch TF outputs for the app defined by $APPNAME and produce a K8s Configmap & Secret YAML populated with those outputs.

set -euo pipefail

# pushd/popd are convenience functions to reduce verbosity on stdout
pushd () {
  command pushd "$@" > /dev/null
}

popd () {
  command popd "$@" > /dev/null
}

ENVIRONS="stage prod"

# TF outputs are namespaced by app name (eg. all outputs for foo app are under the query `jq '.foo.values'`)
# this base filter ensures we only process outputs for the current app
BASE_FILTER=".${APPNAME}.value"

echo "Transforming TF outputs into K8s YAMLs for ${APPNAME}"

for environ in $ENVIRONS; do
  # go get TF output for each environment
  pushd ../../app/${environ}
  tf_outputs=$(tofu output -json | jq "$BASE_FILTER")
  popd

  env_app_length=$(echo ${tf_outputs} | jq 'length')

  if [[ "${env_app_length}" -eq 0 ]]; then
    echo "No ${environ} outputs for ${APPNAME} found."
    continue
  fi

  for output_type in $(jq -r 'keys | join(" ")' <<< "${tf_outputs}"); do
    # count the number of outputs in this output type
    output_length=$(jq -r ".${output_type} | length" <<< "${tf_outputs}")

    # if there are outputs, process them
    if [[ "${output_length}" -gt 0 ]]; then
      # this dirty one liner takes all the TF outputs and makes a string like "KEY1=val1 KEY2=val2..."
      # note: for secrets we need to base64 encode the values
      if [[ ${output_type} == "secret" ]]; then
        env_vars=$(printf '%s' "$tf_outputs" | jq -r ".${output_type} | to_entries | map(\"\(.key)=\(.value | @base64)\") | join(\" \")")
      else
        env_vars=$(printf '%s' "$tf_outputs" | jq -r ".${output_type} | to_entries | map(\"\(.key)=\(.value)\") | join(\" \")")
      fi

      # load the env vars
      eval "export $env_vars"

      template_file="templates/${output_type}-dynamic.yaml.tmpl"

      if [[ ${output_type} == "secret" ]]; then
        # encrypt secrets
        output_file="${environ}/${output_type}-dynamic.yaml.enc"
        echo "Rendering and encrypting ${template_file} into ${output_file}"
        envsubst < "${template_file}" | sops encrypt \
          --encrypted-regex '^(data|stringData)$'\
          --filename-override ${output_file} \
          --input-type yaml \
          --output-type yaml \
          /dev/stdin > ${output_file}
      else
        output_file="${environ}/${output_type}-dynamic.yaml"
        echo "Rendering ${template_file} into ${output_file}"
        envsubst < "${template_file}" > "${output_file}"
      fi

    else
      echo "No TF ${output_type} outputs found for environment ${environ}"
    fi
  done
done
