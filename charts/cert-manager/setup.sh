#!/usr/bin/env bash
## Never call this script directly from this directory.
## It should only be called from the root of the project


CHARTS_DIR=$1
directory=$2
VERSION=$3
UNPREFIXED_VERSION=$4

cp -a external/cert-manager/deploy/charts/cert-manager charts/
mkdir -p charts/cert-manager/crds/
curl -o charts/cert-manager/crds/00-crds.yaml https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml
sed -i "s/^\(appVersion:\s*\).*/\1$VERSION/" "${CHARTS_DIR}/${directory}/Chart.yaml"
sed -i "s/^\(version:\s*\).*/\1$UNPREFIXED_VERSION/" "${CHARTS_DIR}/${directory}/Chart.yaml"
sed -i "s/^\(appVersion:\s*\).*/\1$VERSION/" "${CHARTS_DIR}/${directory}/cainjector/Chart.yaml"
sed -i "s/^\(version:\s*\).*/\1$UNPREFIXED_VERSION/" "${CHARTS_DIR}/${directory}/cainjector/Chart.yaml"
sed -i "s/^\(\s*version:\s*\).*/\1$UNPREFIXED_VERSION/" "${CHARTS_DIR}/${directory}/requirements.yaml"
