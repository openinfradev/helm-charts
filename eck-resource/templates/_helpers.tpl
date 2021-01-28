{{/* vim: set filetype=mustache: */}}
{{- define "eck-resource.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/* Generate basic labels */}}
{{- define "eck-resource.labels" }}
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
{{- end }}
