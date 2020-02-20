#!/usr/bin/env bash

# This script uses arg $1 (name of *.jsonnet file to use) to generate the manifests/*.yaml files.

set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

# Make sure to start with a clean 'manifests' dir
rm -rf manifests
mkdir -p manifests/setup

                                               # optional, but we would like to generate yaml, not json
~/go/bin/jsonnet -J vendor -m manifests "monitoring.jsonnet" | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml;'
# Hotfix to delete compiled configuration
rm -rf manifests/alertmanager-config*