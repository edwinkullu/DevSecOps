{{- define "common.pdb" -}}
{{- $serviceConfig := (index .Values.services .Chart.Name) | default dict -}}
{{- $pdbConfig := $serviceConfig.pdb | default .Values.pdb | default .Values.global.pdb | default dict -}}
{{- if $pdbConfig.enabled -}}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ template "common.name" . }}
  namespace: {{ default .Values.namespace .Values.global.namespace }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  minAvailable: {{ $pdbConfig.minAvailable | default 1 }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
{{- end }}
{{- end -}}
