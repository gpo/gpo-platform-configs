#!/bin/bash

set -euo pipefail

# pushd/popd are convenience functions to reduce verbosity on stdout
pushd () {
  command pushd "$@" > /dev/null
}

popd () {
  command popd "$@" > /dev/null
}

# renders the template and injects a hash of all the inputs at the top of the file
render() {
  local env_vars template input_hash
  env_vars=$1;shift
  template=$1;shift
  input_hash=$1;shift
  printf '# genk8s:hash=%s\n' "${input_hash}"

  # run envsubst in a fresh shell with no env vars (env -i)
  env -i PATH="$PATH" bash -c '
    set -a              # enable allexport (accept all KEY=val pairs as env vars)
    source /dev/stdin   # read our list of KEY=val off stdin
    set +a              # turn it back off
    envsubst < "$1"     # $1 is ${template}
  ' dummyarg0 "${template}" <<<"${env_vars}"
}

ENVIRONS="stage prod"

for environ in $ENVIRONS; do
  # get TF output for this environment
  pushd ../../app/${environ}
  tf_output_json=$(tofu output -json | jq ".${APPNAME}.value")
  popd

  # get secrets for this environment
  secrets_file=secrets.${environ}.json
  if [[ -f "${secrets_file}" ]]; then
    secrets_json=$(sops decrypt "${secrets_file}")
  else
    secrets_json="{}"
  fi

  for template_path in templates/*.tmpl; do
                                          # template_path => templates/foo.yaml.tmpl
    template_file="${template_path##*/}"  # template_file => foo.yaml.tmpl
    template_type="${template_file%%.*}"  # template_type => foo

    # extract any TF outputs for this template
    tf_outputs_for_template=$(jq -r ".\"${template_type}\"" <<<"${tf_output_json}")

    # extract any secrets for this template
    secrets_for_template=$(jq -r ".\"${template_type}\"" <<<"${secrets_json}")

    # count up our goodies
    tf_output_count=$(jq 'length' <<<"${tf_outputs_for_template}")
    secret_count=$(jq 'length' <<<"${secrets_for_template}")

    if [[ $tf_output_count -eq 0 && $secret_count -eq 0 ]]; then
      echo "No TF outputs or Sops secrets found in ${environ} for ${template_path}, skipping."
      continue
    fi

    tf_env_vars=""

    if [[ $tf_output_count -gt 0 ]]; then
      # turn outputs into strings like KEY1=val1 KEY2=val2 for easy exporting
      tf_env_vars=$(printf '%s' "${tf_outputs_for_template}" | jq -r "to_entries | map(\"\(.key)=\(.value)\") | join(\"\n\")")
    fi

    secret_env_vars=""

    if [[ $secret_count -gt 0 ]]; then
      secret_env_vars=$(printf '%s' "${secrets_for_template}" | jq -r "to_entries | map(\"\(.key)=\(.value)\") | join(\"\n\")")
    fi

    all_env_vars=$(printf '%s\n%s\n' "${tf_env_vars}" "${secret_env_vars}")

    # compute a hash of all inputs as well as the template body - if none of these things change, we don't need to re-render
    env_hash=$(md5sum <<<"${all_env_vars}" | awk '{print $1}')
    template_hash=$(md5sum "${template_path}" | awk '{print $1}')
    output_hash=$(printf '%s%s' "${env_hash}" "${template_hash}" | md5sum | awk '{print $1}')

    # if this string is in the template we will encrypt the output
    if grep -q 'genk8s:encrypted=true' "${template_path}"; then
      encrypted_output=true
    else
      encrypted_output=false
    fi

    # foo.yaml.tmpl => foo.yaml
    output_file=${template_file%.*}

    # add the .enc suffix to make it EXTRA obvious that you need to decrypt before using it
    if [[ $encrypted_output = true ]]; then
      output_path="${environ}/${output_file}.enc"
    else
      output_path="${environ}/${output_file}"
    fi

    # if we have rendered this file before, check to see if it needs to change
    if [[ -f "${output_path}" ]]; then
      old_hash=$(grep "genk8s:hash" "${output_path}" | cut -d'=' -f2)
      if [[ "${old_hash}" == "${output_hash}" ]]; then
        echo "${output_path} has not changed, skipping."
        continue
      fi
    fi

    # ensure destination directory exists
    mkdir -p "${environ}"

    if [[ $encrypted_output = true ]]; then

      echo "Rendering and encrypting ${template_file} into ${output_path}"

      # we only want to encrypt the `data` and `stringData` YAML keys
      render "${all_env_vars}" "${template_path}" "${output_hash}" | sops encrypt \
        --filename-override "${output_path}" \
        --encrypted-regex '^(data|stringData)$'\
        --input-type yaml \
        --output-type yaml \
        /dev/stdin > "${output_path}"
    else
      echo "Rendering ${template_path} into ${output_path}"
      render "${all_env_vars}" "${template_path}" "${output_hash}" > "${output_path}"
    fi

  done

done
