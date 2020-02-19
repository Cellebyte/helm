# Schiff Monitoring Prometheus Operator.

## Description

This repository builds up a Setup for the [prometheus-operator](https://github.com/coreos/prometheus-operator) in an HA configuration for local K8s monitoring.
It ensures that prometheus is running and configured as desired for Deduplication and Caching.

The base configuration comes from the repository [kube-prometheus](https://github.com/coreos/kube-prometheus).

## How to build this thing

Install jsonnet or go-jsonnet and the jsonnet bundler.


```Dockerfile
FROM golang:buster

RUN go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
RUN go get github.com/brancz/gojsontoyaml
RUN go get github.com/google/go-jsonnet/cmd/jsonnet
RUN mkdir -p /project/manifests
COPY . /project
RUN jb install

VOLUME /project/manifests

CMD ["bash" "build.sh"]

```


## Basic configuration

To change some configuration of this project look into the config section.

```jsonnet


```