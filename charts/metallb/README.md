# metallb

[MetalLB](https://metallb.universe.tf/faq/) is an open source, rock solid LoadBalancer. It handles the `ServiceType: Loadbalancer`.

## TL;DR;

```console
$ helm repo add cellebyte https://cellebyte.github.io/helm
$ helm install my-release cellebyte/metallb
```

## Introduction

This chart bootstraps a [MetalLB Controller](https://metallb.universe.tf/community/) Controller Deployment and a [MetalLB Speaker](https://metallb.universe.tf/community/) Daemonset on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Prerequisites

- Kubernetes 1.12+
- Helm 2.11+ or Helm 3.0-beta3+
- Virtual IPs for Layer 2 or Route Reflector for BGP setup.

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add cellebyte https://cellebyte.github.io/helm
$ helm install my-release cellebyte/metallb
```

These commands deploy metallb on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` helm release:

```console
$ helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

The following tables lists the configurable parameters of the grafana chart and their default values.

| Parameter                              | Description                                                                                            | Default                                                 |
|----------------------------------------|--------------------------------------------------------------------------------------------------------|---------------------------------------------------------|
| `global.imageRegistry`                 | Global Docker image registry                                                                           | `nil`                                                   |
| `global.imagePullSecrets`              | Global Docker registry secret names as an array                                                        | `[]` (does not add image pull secrets to deployed pods) |
| `controller.image.registry`                       | MetalLB Controller image registry                                                                                 | `docker.io`                                             |
| `controller.image.repository`                     | MetalLB Controller image name                                                                                     | `metallb/controller`                                       |
| `controller.image.tag`                            | MetalLB Controller image tag                                                                                      | `{TAG_NAME}`                                            |
| `controller.pullPolicy`                     | MetalLB Controller image pull policy                                                                              | `IfNotPresent`                                          |
| `controller.image.pullSecrets`                    | Specify docker-registry secret names as an array                                                       | `[]` (does not add image pull secrets to deployed pods) |
| `controller.resources.limits`                    | Specify resource limits which the container is not allowed to succeed.                                                       | `{}` (does not add resource limits to deployed pods) |
| `controller.resources.requests`                    | Specify resource requests which the container needs to spawn.                                                       | `{}` (does not add resource limits to deployed pods) |
| `controller.nodeSelector`                         | Node labels for controller pod assignment                                                                         | `{}`                                                    |
| `controller.tolerations`                          | Tolerations for controller pod assignment                                                                         | `[]`                                                    |
| `controller.affinity`                             | Affinity for controller pod assignment                                                                            | `{}`                                                    |
| `controller.podAnnotations`                       | Controller Pod annotations                                                                                        | `{}`                                                    |
| `controller.serviceAccount.create` | create a serviceAccount for the speaker pod | `true` |
| `controller.serviceAccount.name`   | use the serviceAccount with the specified name | "" |
| `speaker.image.registry`                       | MetalLB Speaker image registry                                                                                 | `docker.io`                                             |
| `speaker.image.repository`                     | MetalLB Speaker image name                                                                                     | `metallb/speaker`                                       |
| `speaker.image.tag`                            | MetalLB Speaker image tag                                                                                      | `{TAG_NAME}`                                            |
| `speaker.pullPolicy`                     | MetalLB Speaker image pull policy                                                                              |`IfNotPresent`                                          |
| `speaker.image.pullSecrets`                    | Specify docker-registry secret names as an array                                                       | `[]` (does not add image pull secrets to deployed pods) |
| `speaker.resources.limits`                    | Specify resource limits which the container is not allowed to succeed.                                                       | `{}` (does not add resource limits to deployed pods) |
| `speaker.resources.requests`                    | Specify resource requests which the container needs to spawn.                                                       | `{}` (does not add resource limits to deployed pods) |
| `speaker.nodeSelector`                         | Node labels for speaker pod assignment                                                                         | `{}`                                                    |
| `speaker.tolerations`                          | Tolerations for speaker pod assignment                                                                         | `[]`                                                    |
| `speaker.affinity`                             | Affinity for speaker pod assignment                                                                            | `{}`                                                    |
| `speaker.podAnnotations`                       | Speaker Pod annotations                                                                                        | `{}`                                                    |
| `speaker.serviceAccount.create` | create a serviceAccount for the speaker pod | `true` |
| `speaker.serviceAccount.name`   | use the serviceAccount with the specified name | "" |
| `nameOverride`                         | String to partially override grafana.fullname template with a string (will prepend the release name)   | `nil`                                                   |
| `fullnameOverride`                     | String to fully override grafana.fullname template with a string                                       | `nil`                                                                                  |
| `livenessProbe.enabled`                | Enable/disable the Liveness probe                                                                      | `true`                                                  |
| `livenessProbe.initialDelaySeconds`    | Delay before liveness probe is initiated                                                               | `60`                                                    |
| `livenessProbe.periodSeconds`          | How often to perform the probe                                                                         | `10`                                                    |
| `livenessProbe.timeoutSeconds`         | When the probe times out                                                                               | `5`                                                     |
| `livenessProbe.successThreshold`       | Minimum consecutive successes for the probe to be considered successful after having failed.           | `1`                                                     |
| `livenessProbe.failureThreshold`       | Minimum consecutive failures for the probe to be considered failed after having succeeded.             | `6`                                                     |

## Configuration

To configure [MetalLB](https://metallb.universe.tf) please look into the configuration section [MetalLB Configuration](https://metallb.universe.tf/configuration/).

### Example Layer 2 configuration

```yaml
configInline:
  # The address-pools section lists the IP addresses that MetalLB is
  # allowed to allocate, along with settings for how to advertise
  # those addresses over BGP once assigned. You can have as many
  # address pools as you want.
  address-pools:
  - # A name for the address pool. Services can request allocation
    # from a specific address pool using this name, by listing this
    # name under the 'metallb.universe.tf/address-pool' annotation.
    name: generic-cluster-pool
    # Protocol can be used to select how the announcement is done.
    # Supported values are bgp and layer2.
    protocol: layer2
    # A list of IP address ranges over which MetalLB has
    # authority. You can list multiple ranges in a single pool, they
    # will all share the same settings. Each range can be either a
    # CIDR prefix, or an explicit start-end range of IPs.
    addresses:
    - 10.27.50.30-10.27.50.35
```