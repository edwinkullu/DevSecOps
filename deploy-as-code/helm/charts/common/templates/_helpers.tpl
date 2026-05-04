{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "common.labels" -}}
app: {{ template "common.name" . }}
{{- $envSuffix := .Values.env_suffix | default .Values.global.env_suffix -}}
{{- if $envSuffix }}
env: {{ $envSuffix }}
{{- end }}
{{- if .Values.labels }}
{{- if .Values.labels.group }}      
group: {{ .Values.labels.group }}  
{{- end }}
{{- end }}
{{- range $key, $val := .Values.additionalLabels }}
{{ $key }}: {{ $val | quote }}
{{- end }}    
{{- end }}

{{/*
Selector labels used to identify resources - MUST BE IMMUTABLE
*/}}
{{- define "common.selectorLabels" -}}
app: {{ template "common.name" . }}
{{- end }}

{{- define "common.image" -}}
{{- $tag := .tag | default .Values.global.current_tag | default "latest" -}}
{{- if .repository -}}
  {{- if contains "/" .repository -}}      
    {{- printf "%s:%s" .repository $tag -}}
  {{- else -}}
    {{- printf "%s/%s:%s" (required "global.registry_base_url is required" .Values.global.registry_base_url) .repository $tag -}}
  {{- end -}}
{{- else -}}
  {{- printf "PLACEHOLDER_IMAGE:%s" $tag -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
