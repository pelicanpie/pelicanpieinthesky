#!/bin/bash
# Switches to the appropriate terraform workspace
# Runs the supplied terraform command
# Usage:
#   tf.sh apply recipe_backend -e=dev

project_name="pelicanpieinthesky"

cmd="$1"
shift
stack="$1"
shift

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -e=*|--env=*) env="${key#*=}"; shift;;
esac
done

if [ -z $env ]; then
    echo "missing required parameter --env"
    exit 1
fi

current_dir=`pwd`
tf_dir="./terraform/stacks"
tf_config_dir="../../config/$env"

echo "Running init"
terraform \
-chdir="${tf_dir}/${stack}" \
init \
-backend-config="${tf_config_dir}/common_backend.tf" \
-backend-config="key=${env}/${stack}/terraform.tfstate"
-var-file="${tf_config_dir}/common.tfvars" \
-var-file="${tf_config_dir}/${stack}"

echo "Running $cmd"
terraform \
-chdir="${tf_dir}/${stack}" \
$cmd \
-var-file="${tf_config_dir}/common.tfvars" \
-var-file="${tf_config_dir}/${stack}" \
