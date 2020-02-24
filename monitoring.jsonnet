local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
local secret = k.core.v1.secret;
local ingress = k.networking.v1beta1.ingress;
local service = k.core.v1.service;
local container = k.apps.v1.deployment.mixin.spec.template.spec.containersType;
local containerPort = container.portsType;
local deployment = k.apps.v1.deployment;
local ingressTls = ingress.mixin.spec.tlsType;
local ingressRule = ingress.mixin.spec.rulesType;
local httpIngressPath = ingressRule.mixin.http.pathsType;
local pvc = k.core.v1.persistentVolumeClaim;
local servicePort = k.core.v1.service.mixin.spec.portsType;
local prometheusPort = servicePort.newNamed('web', 9090, 'web');
local thanosPort = servicePort.newNamed('http', 9090, 'http');
local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') +
  (import 'kube-prometheus/kube-prometheus-thanos-sidecar.libsonnet') +
  {
    _config+:: {
      namespace: 'monitoring-system',
      externalBaseFqdn: 'k8s.cluster.local',
      customer: '<customer>',
      cluster: '<cluster>',
      thanosQueryServiceName: 'thanos-query',


      versions+:: {
        alertmanager: 'v0.20.0',
        nodeExporter: 'v0.18.1',
        kubeStateMetrics: 'v1.9.4',
        kubeRbacProxy: 'v0.4.1',
        prometheusOperator: 'v0.36.0',
        prometheus: 'v2.16.0',
        thanos: 'v0.10.1',
        grafana: '6.6.1'
      },
      grafana+:: {
        datasources:: [{
          name: 'prometheus',
          type: 'prometheus',
          access: 'proxy',
          orgId: 1,
          url: 'http://' + $._config.thanosQueryServiceName + '.' + $._config.namespace + '.svc:9090',
          version: 1,
          editable: false,
        }],
        config+: {
          sections+: {
            server+: {
              root_url: 'https://grafana.' + $._config.externalBaseFqdn + '/',
              // handle dex integration here to support OpenID for the customer.
            },
          },
        },
      },
    },

    alertmanager+:: {
      config: importstr 'alertmanager-config.yaml',
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          thanos+: {
            // make this field hidden so it is not rendered
            objectStorageConfig:: null,
          },
          // https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#prometheusspec
          // If a value isn't specified for 'retention', then by default the '--storage.tsdb.retention=24h' arg will be passed to prometheus by prometheus-operator.
          // The possible values for a prometheus <duration> are:
          //  * https://github.com/prometheus/common/blob/c7de230/model/time.go#L178 specifies "^([0-9]+)(y|w|d|h|m|s|ms)$" (years weeks days hours minutes seconds milliseconds)
          retention: '20d',
          externalUrl: 'http://prometheus.' + $._config.externalBaseFqdn,
          externalLabels: {
            customer: $._config.customer,
            cluster: $._config.cluster,
          },
          // Reference info: https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/storage.md
          // By default (if the following 'storage.volumeClaimTemplate' isn't created), prometheus will be created with an EmptyDir for the 'prometheus-k8s-db' volume (for the prom tsdb).
          // This 'storage.volumeClaimTemplate' causes the following to be automatically created (via dynamic provisioning) for each prometheus pod:
          //  * PersistentVolumeClaim (and a corresponding PersistentVolume)
          //  * the actual volume (per the StorageClassName specified below)
          storage: {  // https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#storagespec
            volumeClaimTemplate:  // (same link as above where the 'pvc' variable is defined)
              pvc.new() +  // http://g.bryan.dev.hepti.center/core/v1/persistentVolumeClaim/#core.v1.persistentVolumeClaim.new

              pvc.mixin.spec.withAccessModes('ReadWriteOnce') +

              // https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#resourcerequirements-v1-core (defines 'requests'),
              // and https://kubernetes.io/docs/concepts/policy/resource-quotas/#storage-resource-quota (defines 'requests.storage')
              // pvc.mixin.spec.resources.withRequests({ storage: '50Gi' }) + // production storage class
              pvc.mixin.spec.resources.withRequests({ storage: '5Gi' }) +  // For local deployment

              // A StorageClass of the following name (which can be seen via `kubectl get storageclass` from a node in the given K8s cluster) must exist prior to kube-prometheus being deployed.
              // pvc.mixin.spec.withStorageClassName('ssd'),   // production storage class
              pvc.mixin.spec.withStorageClassName('standard'),  //for local deployment

            // The following 'selector' is only needed if you're using manual storage provisioning (https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/storage.md#manual-storage-provisioning).
            // And note that this is not supported/allowed by AWS - uncommenting the following 'selector' line (when deploying kube-prometheus to a K8s cluster in AWS) will cause the pvc to be stuck in the Pending status and have the following error:
            //  * 'Failed to provision volume with StorageClass "ssd": claim.Spec.Selector is not supported for dynamic provisioning on AWS'
            //pvc.mixin.spec.selector.withMatchLabels({}),
          },  // storage
        },  // spec
      },  // prometheus
    },  //
    thanos+:: {
      "query-deployment":
        local podLabels = {
          app: "thanos-query",
        };
        deployment.new(
          $._config.thanosQueryServiceName,
          2,
          container.new("thanos-query", $._config.imageRepos.thanos + ":" + $._config.versions.thanos) +
          container.withPorts([
            containerPort.newNamed(10902, "http"),
            containerPort.newNamed(10901, "grpc"),
          ],
          ) + 
          container.withArgs([
            'query',
            '--log.level=info',
            '--query.replica-label=prometheus_replica',
            '--store=dnssrv+_grpc._tcp.' + $.prometheus.service.metadata.name + '.' + $._config.namespace +'.svc.cluster.local',
          ]),
          podLabels,
        ) + 
        deployment.mixin.metadata.withNamespace($._config.namespace) +
        deployment.mixin.metadata.withLabels(podLabels) +
        deployment.mixin.spec.selector.withMatchLabels(podLabels),
      "query-service":
        service.new(
          $._config.thanosQueryServiceName,
          {
            app: 'thanos-query',
          },
          thanosPort
        ) +
        service.mixin.spec.withSessionAffinity('ClientIP') +
        service.mixin.metadata.withNamespace($._config.namespace) +
        service.mixin.metadata.withLabels({ app: 'thanos-query' }),
    },
    ingress+:: {
      grafana:
        ingress.new() +
        ingress.mixin.metadata.withName('grafana') +
        ingress.mixin.metadata.withNamespace($._config.namespace) +
        ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost('grafana.' + $._config.externalBaseFqdn) +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName('grafana') +
            httpIngressPath.mixin.backend.withServicePort('http')
          ),
        ),
      // prometheus federation setup with an ingress per prometheus instance
      'prometheus-service-0':
        service.new(
          $.prometheus.service.metadata.name + '-0',
          {
            app: 'prometheus',
            prometheus: $._config.prometheus.name,
            "statefulset.kubernetes.io/pod-name": $.prometheus.service.metadata.name + '-0',
          },
          prometheusPort
        ) +
        service.mixin.spec.withSessionAffinity('ClientIP') +
        service.mixin.metadata.withNamespace($._config.namespace) +
        service.mixin.metadata.withLabels({ prometheus: $._config.prometheus.name }),
      'prometheus-0':
        ingress.new() +
        ingress.mixin.metadata.withName($.prometheus.service.metadata.name + '-0') +
        ingress.mixin.metadata.withNamespace($._config.namespace) +
        ingress.mixin.metadata.withAnnotations({
          'nginx.ingress.kubernetes.io/auth-type': 'basic',
          'nginx.ingress.kubernetes.io/auth-secret': 'basic-auth',
          'nginx.ingress.kubernetes.io/auth-realm': 'Authentication Required',
        }) +
        ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost('prometheus-1.' + $._config.externalBaseFqdn) +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName($.prometheus.service.metadata.name + '-0') +
            httpIngressPath.mixin.backend.withServicePort('web')
          ),
        ),
      'prometheus-service-1':
        service.new(
          $.prometheus.service.metadata.name + '-1',
          {
            app: 'prometheus',
            prometheus: $.prometheus.name,
            "statefulset.kubernetes.io/pod-name": $.prometheus.service.metadata.name + '-1',
          },
          prometheusPort
        ) +
        service.mixin.spec.withSessionAffinity('ClientIP') +
        service.mixin.metadata.withNamespace($._config.namespace) +
        service.mixin.metadata.withLabels({ prometheus: $.prometheus.name }),
      'prometheus-1':
        ingress.new() +
        ingress.mixin.metadata.withName($.prometheus.service.metadata.name + '-1') +
        ingress.mixin.metadata.withNamespace($._config.namespace) +
        ingress.mixin.metadata.withAnnotations({
          'nginx.ingress.kubernetes.io/auth-type': 'basic',
          'nginx.ingress.kubernetes.io/auth-secret': 'basic-auth',
          'nginx.ingress.kubernetes.io/auth-realm': 'Authentication Required',
        }) +
        ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost('prometheus-2.' + $._config.externalBaseFqdn) +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName($.prometheus.service.metadata.name + '-1') +
            httpIngressPath.mixin.backend.withServicePort('web')
          ),
        ),
    },
  } + {
    // Create basic auth secret - replace 'auth' file with your own
    ingress+:: {
      'basic-auth-secret':
        secret.new('basic-auth', { auth: std.base64(importstr 'auth') }) +
        secret.mixin.metadata.withNamespace($._config.namespace),
    },
  };

{ ['setup/0namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor'), std.objectFields(kp.prometheusOperator))
} +
// serviceMonitor is separated so that it can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
{ ['ingress-' + name]: kp.ingress[name] for name in std.objectFields(kp.ingress) } +
{ ['thanos-' + name]: kp.thanos[name] for name in std.objectFields(kp.thanos) }
