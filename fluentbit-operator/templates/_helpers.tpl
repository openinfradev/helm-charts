{{/* vim: set filetype=mustache: */}}
{{/* Expand the name of the chart. This is suffixed with -alertmanager, which means subtract 13 from longest 63 available */}}
{{- define "fluentbit-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created adds and extra 37 characters, so truncation should be 63-35=26.
*/}}
{{- define "fluentbit-operator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 26 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Fullname suffixed with operator */}}
{{- define "fluentbit-operator.operator.fullname" -}}
{{- printf "%s-operator" (include "fluentbit-operator.fullname" .) -}}
{{- end }}

{{/* Fullname suffixed with fluentbit */}}
{{- define "fluentbit-operator.fluentbit.fullname" -}}
{{- printf "%s-fluentbit" (include "fluentbit-operator.fullname" .) -}}
{{- end }}

{{/* Fullname suffixed with operator */}}
{{- define "fluentbit-operator.exporter.fullname" -}}
{{- printf "alerted-log-exporter" -}}
{{- end }}

{{/* Fullname suffixed with alertmanager */}}
{{- define "fluentbit-operator.alertmanager.fullname" -}}
{{- printf "%s-alertmanager" (include "fluentbit-operator.fullname" .) -}}
{{- end }}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "fluentbit-operator.chartref" -}}
{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end }}

{{/* Generate basic labels */}}
{{- define "fluentbit-operator.labels" }}
chart: {{ template "fluentbit-operator.chartref" . }}
release: {{ $.Release.Name | quote }}
heritage: {{ $.Release.Service | quote }}
{{- if .Values.commonLabels}}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/* Create the name of fluentbit-operator service account to use */}}
{{- define "fluentbit-operator.operator.serviceAccountName" -}}
{{- if .Values.fluentbitOperator.serviceAccount.create -}}
    {{ default (include "fluentbit-operator.operator.fullname" .) .Values.fluentbitOperator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.fluentbitOperator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Create the name of fluentbit service account to use */}}
{{- define "fluentbit-operator.fluentbit.serviceAccountName" -}}
{{- if .Values.fluentbit.serviceAccount.create -}}
    {{ default (include "fluentbit-operator.fluentbit.fullname" .) .Values.fluentbit.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.fluentbit.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Create the name of alertmanager service account to use */}}
{{- define "fluentbit-operator.alertmanager.serviceAccountName" -}}
{{- if .Values.alertmanager.serviceAccount.create -}}
    {{ default (include "fluentbit-operator.alertmanager.fullname" .) .Values.alertmanager.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.alertmanager.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Generate output for elasticsearch */}}
{{- define "fluentbit-operator.fluentbit.output.es" -}}
{{- $envAll := index . 0 -}}
{{- $input := index . 1 -}}
{{- $index := index . 2 -}}
{{- $tag := index . 3 -}}
---
# Elasticsearch index 
apiVersion: logging.kubesphere.io/v1alpha2
kind: Output
metadata:
  name: {{ template "fluentbit-operator.fullname" $envAll  }}-es-{{ $index }}
  namespace: {{ $envAll.Release.Namespace }}
  labels:
    logging.kubesphere.io/enabled: "true"
    app.kubernetes.io/version: v0.0.1
spec:
  match: {{ $tag | quote }}
  es:
{{- if $input.logstashFormat}}
    logstashPrefix: {{ $index }}
    logstashFormat: true
{{- else if $index }}
    index: {{ $index }}
{{- end}}
    host: {{ $envAll.Values.fluentbit.outputs.es.host }}
    port: {{ $envAll.Values.fluentbit.outputs.es.port }}
    type: {{ $input.type }}
    httpUser:
      valueFrom:
        secretKeyRef:
          name: {{ $envAll.Values.fluentbit.outputs.es.username }}-es-secret
          key: username
    httpPassword:
      valueFrom:
        secretKeyRef:
          name: {{ $envAll.Values.fluentbit.outputs.es.username }}-es-secret
          key: password
    tls:
      verify: false
{{- end -}}