{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "custom-network.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "custom-network.fullname" -}}
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
{{- define "custom-network.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "custom-network.labels" -}}
app.kubernetes.io/name: {{ include "custom-network.name" . }}
helm.sh/chart: {{ include "custom-network.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "custom-network.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "custom-network.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Create F5 ingress 
*/}}
{{- define "custom-network.genf5Ingress" -}}
{{- $envAll := index . 0 -}}
{{- $info := index . 1 -}}
{{- $name := index . 2 -}}
{{- $ip := index . 3 -}}

{{/*- if semverCompare ">=1.14-0" $envAll.Capabilities.KubeVersion.GitVersion }}
apiVersion: networking.k8s.io/v1beta1
{{- else -}}
apiVersion: extensions/v1beta1
{{- end */}}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ $name }}
{{- if $info.namespace}}
  namespace: {{ $info.namespace }}
{{- end}}
  labels:
    {{- include "custom-network.labels" $envAll | nindent 4 }}
  annotations:
    virtual-server.f5.com/ip: {{ $ip }}
    virtual-server.f5.com/partition: {{ $info.f5.partition}}
{{- if $info.f5.annotations}}
    {{- toYaml $info.f5.annotations | nindent 4 }}
{{- end}}
{{- if $info.f5.healthcheck}}
    virtual-server.f5.com/health: |
        [
          {
            "path":     {{$info.f5.healthcheck.path| quote}},
 {{- if $info.f5.healthcheck.url}}
            "send":     "HTTP GET {{$info.f5.healthcheck.url}}",
 {{- else}}
            "send":     "HTTP GET /",
 {{- end}}
            "interval": 5,
            "timeout":  10
          }
        ]
{{- end}}
spec:
{{- if $info.tls }}
  tls:
  {{- range $info.tls }}
    - secretName: {{ .secretName }}
    {{- if .hosts}}
      hosts:
      {{- range .hosts }}
      - {{ . | quote }}
      {{- end }}
    {{- end}}
  {{- end }}
{{- end }}
  rules:
  {{- range $info.rules }}
    - host: {{ .host | quote }}
      http:
        paths:
        {{- range .paths }}
          - path: {{ .path }}
            backend:
              serviceName: {{ .serviceName }}
              servicePort: {{ .servicePort }}
        {{- end }}
  {{- end }}

{{- end -}}
