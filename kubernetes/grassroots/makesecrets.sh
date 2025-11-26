#!/bin/bash

# this script will fetch TF outputs for this app and produce a K8s Configmap & Secret YAML populated with those outputs.

pushd () {
  command pushd "$@" > /dev/null
}

popd () {
  command popd "$@" > /dev/null
}

APPNAME=grassroots
ENVIRONS="stage prod"
OUTPUT_TYPES="configs secrets"
WORKDIR=$PWD

# tf outputs are produced on a per-app basis (eg. all outputs for foo app are under the query `jq '.foo.values'`) so this base filter ensures we only process outputs for the current app
BASE_FILTER=".${APPNAME}.value"

# clean up old data if present
rm -rf output.*.json
rm -rf stage/*.env
rm -rf prod/*.env

for environ in $ENVIRONS; do
  tf_file=tf_output.${environ}.json

  # go get TF output for each environment
  pushd ../../app/${environ}
  tofu output -json | jq "$BASE_FILTER" > ${WORKDIR}/${tf_file}
  popd

  for output_type in $OUTPUT_TYPES; do
    # count the number of outputs
    output_length=$(jq 'length' "${tf_file}")

    # if there are outputs, process them
    if [[ "${output_length}" -gt 0 ]]; then
      outfile="${environ}/${output_type}.env"
      echo "Rendering ${outfile}"
      # extract all .configs or .secrets, render them as KEY=VALUE and write them to .env file
      echo "# This file is generated dynamically by ${0}, hand edits will be overwritten!" > ${outfile}
      jq -rf <(printf '%s | to_entries[] | "\(.key)=\(.value)"' ".${output_type}") "${tf_file}" >> ${outfile}
    else
      echo "No ${output_type} outputs found for environment ${environ}, skipping it."
    fi
  done
done
