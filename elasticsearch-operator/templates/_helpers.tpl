{{/* vim: set filetype=mustache: */}}
{{- define "elasticsearch-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/* Generate basic labels */}}
{{- define "elasticsearch-operator.labels" }}
release {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
{{- end }}
