{{/*
Expand the name of the chart.
*/}}
{{- define "tks-info.name" -}}
{{- default .Chart.Name .Values.tksinfo.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "tks-info.fullname" -}}
{{- if .Values.tksinfo.fullnameOverride }}
{{- .Values.tksinfo.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Values.tksinfo.nameOverride }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tks-info.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tks-info.labels" -}}
helm.sh/chart: {{ include "tks-info.chart" . }}
{{ include "tks-info.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tks-info.selectorLabels" -}}
app.kubernetes.io/service: tks
app.kubernetes.io/name: {{ include "tks-info.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tks-info.serviceAccountName" -}}
{{- if .Values.tksinfo.serviceAccount.create }}
{{- default (include "tks-info.fullname" .) .Values.tksinfo.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tksinfo.serviceAccount.name }}
{{- end }}
{{- end }}
