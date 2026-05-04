{{- define "common.backendConfig" -}}
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: {{ template "common.name" . }}-tcp-hc
  namespace: {{ default .Values.namespace .Values.global.namespace }}
spec:
  healthCheck:
    checkIntervalSec: 15
    timeoutSec: 5
    healthyThreshold: 1
    unhealthyThreshold: 3
    type: TCP
    port: {{ .Values.httpPort | default 8080 }}
{{- end }}

{{- define "common.healthCheckPolicy" -}}
apiVersion: networking.gke.io/v1
kind: HealthCheckPolicy
metadata:
  name: {{ template "common.name" . }}-hc-policy
  namespace: {{ default .Values.namespace .Values.global.namespace }}
spec:
  default:
    checkIntervalSec: 15
    timeoutSec: 5
    healthyThreshold: 1
    unhealthyThreshold: 3
    config:
      type: TCP
      tcpHealthCheck:
        port: {{ .Values.httpPort | default 8080 }}
  targetRef:
    group: ""
    kind: Service
    name: {{ template "common.name" . }}
{{- end }}
