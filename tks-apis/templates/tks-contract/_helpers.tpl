{{/*
Expand the name of the chart.
*/}}
{{- define "tks-contract.name" -}}
{{- default .Chart.Name .Values.tkscontract.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "tks-contract.fullname" -}}
{{- if .Values.tkscontract.fullnameOverride }}
{{- .Values.tkscontract.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Values.tkscontract.nameOverride }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tks-contract.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tks-contract.labels" -}}
helm.sh/chart: {{ include "tks-contract.chart" . }}
{{ include "tks-contract.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tks-contract.selectorLabels" -}}
app.kubernetes.io/service: tks
app.kubernetes.io/name: {{ include "tks-contract.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tks-contract.serviceAccountName" -}}
{{- if .Values.tkscontract.serviceAccount.create }}
{{- default (include "tks-contract.fullname" .) .Values.tkscontract.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tkscontract.serviceAccount.name }}
{{- end }}
{{- end }}
