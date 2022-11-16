{{/*
Expand the name of the chart.
*/}}
{{- define "tks-admin-console.name" -}}
{{- default .Chart.Name .Values.tksadminconsole.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "tks-admin-console.fullname" -}}
{{- if .Values.tksadminconsole.fullnameOverride }}
{{- .Values.tksadminconsole.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Values.tksadminconsole.nameOverride }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tks-admin-console.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tks-admin-console.labels" -}}
helm.sh/chart: {{ include "tks-admin-console.chart" . }}
{{ include "tks-admin-console.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tks-admin-console.selectorLabels" -}}
app.kubernetes.io/service: tks
app.kubernetes.io/name: {{ include "tks-admin-console.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tks-admin-console.serviceAccountName" -}}
{{- if .Values.tksadminconsole.serviceAccount.create }}
{{- default (include "tks-admin-console.fullname" .) .Values.tksadminconsole.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tksadminconsole.serviceAccount.name }}
{{- end }}
{{- end }}
