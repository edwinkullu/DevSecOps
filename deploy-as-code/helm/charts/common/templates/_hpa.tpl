{{- define "common.hpa" -}}
{{- $serviceConfig := (index .Values.services .Release.Name) | default dict -}}
{{- $hpaConfig := $serviceConfig.hpa | default .Values.hpa | default dict -}}
{{- if or .Values.hpa.enabled $hpaConfig.enabled -}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ template "common.name" . }}
  namespace: {{ default .Values.namespace .Values.global.namespace }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ template "common.name" . }}
  minReplicas: {{ $hpaConfig.min | default .Values.hpa.minReplicas | default 2 }}
  maxReplicas: {{ $hpaConfig.max | default .Values.hpa.maxReplicas | default 5 }}
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ $hpaConfig.memoryThreshold | default .Values.hpa.memoryThreshold | default 70 }}
{{- end }}
{{- end -}}
