{{/*
Expand the name of the chart.
*/}}
{{- define "tks-console.name" -}}
{{- default .Chart.Name .Values.tksconsole.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "tks-console.fullname" -}}
{{- if .Values.tksconsole.fullnameOverride }}
{{- .Values.tksconsole.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Values.tksconsole.nameOverride }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tks-console.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tks-console.labels" -}}
helm.sh/chart: {{ include "tks-console.chart" . }}
{{ include "tks-console.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tks-console.selectorLabels" -}}
app.kubernetes.io/service: tks
app.kubernetes.io/name: {{ include "tks-console.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tks-console.serviceAccountName" -}}
{{- if .Values.tksconsole.serviceAccount.create }}
{{- default (include "tks-console.fullname" .) .Values.tksconsole.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tksconsole.serviceAccount.name }}
{{- end }}
{{- end }}
