#!/usr/bin/env bash
cp -a external/cert-manager/deploy/charts/cert-manager charts/
mkdir -p charts/cert-manager/crds/
curl -o charts/cert-manager/crds/00-crds.yaml https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml
