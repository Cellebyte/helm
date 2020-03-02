# Thanos flavoured Prometheus Operator.

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


## The helm chart stuff

The current diff between the control-plane and the tenant clusters.

```txt
├── .
└── prometheus-thanos-operator
    ├── control-plane
    │   └── monitoring-system
    │       ├── grafana
    │       │   ├── configuration
    │       │   └── dashboards
    │       ├── local_debugging_helm-values
    │       └── prometheus
    │           ├── federation
    │           └── rules
    ├── local_debugging_helm-values
    └── tenant
        └── monitoring-system
            ├── grafana
            │   ├── configuration
            │   └── dashboards
            └── prometheus
                ├── federation
                └── rules
 
```



```txt
### only in the control-plane cluster ###
Only in prometheus-thanos-operator/control-plane/monitoring-system/prometheus/federation: additional-scrape-configs.yaml

### only in the tenant clusters ###
Only in prometheus-thanos-operator/tenant/monitoring-system/prometheus/federation: ingress-prometheus-0.yaml
Only in prometheus-thanos-operator/tenant/monitoring-system/prometheus/federation: ingress-prometheus-1.yaml
Only in prometheus-thanos-operator/tenant/monitoring-system/prometheus/federation: ingress-prometheus-service-0.yaml
Only in prometheus-thanos-operator/tenant/monitoring-system/prometheus/federation: ingress-prometheus-service-1.yaml
Only in prometheus-thanos-operator/tenant/monitoring-system/prometheus/federation: secret-ingress-prometheus.yaml


123c123,124
<         environment: "production"
---
>         customer: "<customer>"
>         cluster: "<cluster>"
224c225
<       additionalScrapeConfigsExternal: true
---
>       additionalScrapeConfigsExternal: false
```