{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "thanos-prometheus-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "thanos-prometheus-operator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "thanos-prometheus-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "thanos-prometheus-operator.labels" -}}
helm.sh/chart: {{ include "thanos-prometheus-operator.chart" . }}
{{ include "thanos-prometheus-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "thanos-prometheus-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "thanos-prometheus-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "thanos-prometheus-operator.datasources" -}}
{{ printf "{\"apiVersion\":1,\"datasources\":[{\"access\":\"proxy\",\"editable\":false,\"name\":\"prometheus\",\"orgId\":1,\"type\":\"prometheus\",\"url\":\"http://%s-%s.%s.svc:9090\",\"version\":1}]}" (include "thanos-prometheus-operator.fullname" .) "query-querier" .Release.Namespace | b64enc }}
{{- end -}}

{{- define "thanos-prometheus-operator.hostname" -}}
{{ printf "prometheus-%d.%s" .extra .root.Values.federation.ingress.baseFQDN }}
{{- end -}}

{{- define "thanos-prometheus-operator.serviceName" -}}
{{ printf "%s-prometheus-%d" (include "thanos-prometheus-operator.fullname" .root) .extra }}
{{- end -}}

{{- define "thanos-prometheus-operator.pod" -}}
{{ printf "prometheus-%s-prometheus-%d" (include "thanos-prometheus-operator.fullname" .root) .extra }}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "thanos-prometheus-operator.tplValue" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "thanos-prometheus-operator.tplValue" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}