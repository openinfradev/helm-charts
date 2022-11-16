{{/*
Expand the name of the chart.
*/}}
{{- define "tks-batch.name" -}}
{{- default .Chart.Name .Values.tksbatch.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "tks-batch.fullname" -}}
{{- if .Values.tksbatch.fullnameOverride }}
{{- .Values.tksbatch.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Values.tksbatch.nameOverride }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tks-batch.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tks-batch.labels" -}}
helm.sh/chart: {{ include "tks-batch.chart" . }}
{{ include "tks-batch.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tks-batch.selectorLabels" -}}
app.kubernetes.io/service: tks
app.kubernetes.io/name: {{ include "tks-batch.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tks-batch.serviceAccountName" -}}
{{- if .Values.tksbatch.serviceAccount.create }}
{{- default (include "tks-batch.fullname" .) .Values.tksbatch.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tksbatch.serviceAccount.name }}
{{- end }}
{{- end }}
