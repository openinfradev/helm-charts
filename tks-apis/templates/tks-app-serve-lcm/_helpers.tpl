{{/*
Expand the name of the chart.
*/}}
{{- define "tks-app-serve-lcm.name" -}}
{{- default .Chart.Name .Values.tksappservelcm.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "tks-app-serve-lcm.fullname" -}}
{{- if .Values.tksappservelcm.fullnameOverride }}
{{- .Values.tksappservelcm.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Values.tksappservelcm.nameOverride }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tks-app-serve-lcm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tks-app-serve-lcm.labels" -}}
helm.sh/chart: {{ include "tks-app-serve-lcm.chart" . }}
{{ include "tks-app-serve-lcm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tks-app-serve-lcm.selectorLabels" -}}
app.kubernetes.io/service: tks
app.kubernetes.io/name: {{ include "tks-app-serve-lcm.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tks-app-serve-lcm.serviceAccountName" -}}
{{- if .Values.tksappservelcm.serviceAccount.create }}
{{- default (include "tks-app-serve-lcm.fullname" .) .Values.tksappservelcm.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tksappservelcm.serviceAccount.name }}
{{- end }}
{{- end }}
