{{/*
Expand the name of the chart.
*/}}
{{- define "tks-cluster-lcm.name" -}}
{{- default .Chart.Name .Values.tksclusterlcm.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "tks-cluster-lcm.fullname" -}}
{{- if .Values.tksclusterlcm.fullnameOverride }}
{{- .Values.tksclusterlcm.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Values.tksclusterlcm.nameOverride }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tks-cluster-lcm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tks-cluster-lcm.labels" -}}
helm.sh/chart: {{ include "tks-cluster-lcm.chart" . }}
{{ include "tks-cluster-lcm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tks-cluster-lcm.selectorLabels" -}}
app.kubernetes.io/service: tks
app.kubernetes.io/name: {{ include "tks-cluster-lcm.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tks-cluster-lcm.serviceAccountName" -}}
{{- if .Values.tksclusterlcm.serviceAccount.create }}
{{- default (include "tks-cluster-lcm.fullname" .) .Values.tksclusterlcm.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tksclusterlcm.serviceAccount.name }}
{{- end }}
{{- end }}
