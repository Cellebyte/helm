#!/usr/bin/env bash
## Never call this script directly from this directory.
## It should only be called from the root of the project


CHARTS_DIR=$1
directory=$2
VERSION=$3
UNPREFIXED_VERSION=$4


mkdir -p "${CHARTS_DIR}/${directory}/crds/"
cd external/${directory}/library/ && find . -name '*template.yaml' -exec cp --parents \{\} "../../../${CHARTS_DIR}/${directory}/crds/" \; && cd ../../../
sed -i "s/^\(appVersion:\s*\).*/\1$VERSION/" "${CHARTS_DIR}/${directory}/Chart.yaml"
