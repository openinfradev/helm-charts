{{/*
Expand the name of the chart.
*/}}
{{- define "tks-api.name" -}}
{{- default .Chart.Name .Values.tksapi.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "tks-api.fullname" -}}
{{- if .Values.tksapi.fullnameOverride }}
{{- .Values.tksapi.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Values.tksapi.nameOverride }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tks-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tks-api.labels" -}}
helm.sh/chart: {{ include "tks-api.chart" . }}
{{ include "tks-api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tks-api.selectorLabels" -}}
app.kubernetes.io/service: tks
app.kubernetes.io/name: {{ include "tks-api.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tks-api.serviceAccountName" -}}
{{- if .Values.tksapi.serviceAccount.create }}
{{- default (include "tks-api.fullname" .) .Values.tksapi.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tksapi.serviceAccount.name }}
{{- end }}
{{- end }}
