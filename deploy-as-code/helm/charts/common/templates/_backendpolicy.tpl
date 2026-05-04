{{- define "common.backendpolicy" -}}
{{- if and .Values.global .Values.global.gateway .Values.global.gateway.enabled }}
apiVersion: networking.gke.io/v1
kind: GCPBackendPolicy
metadata:
  name: {{ template "common.name" . }}-backend-policy
  namespace: {{ default .Values.namespace .Values.global.namespace }}
spec:
  default:
    {{- if .Values.timeoutSec }}
    timeoutSec: {{ .Values.timeoutSec }}
    {{- end }}
    {{- if .Values.global.gateway.securityPolicyName }}
    securityPolicy: {{ .Values.global.gateway.securityPolicyName }}
    {{- end }}
    {{- if .Values.trafficDuration }}
    trafficDuration: {{ .Values.trafficDuration }}
    {{- end }}
    {{- if .Values.balancingMode }}
    balancingMode: {{ .Values.balancingMode }}
    {{- end }}
    {{- if and .Values.global.gateway.cdn .Values.global.gateway.cdn.enabled (ne .Values.cdn_enabled false) }}
    cdn:
      enabled: true
    {{- end }}
  targetRef:
    group: ""
    kind: Service
    name: {{ template "common.name" . }}
{{- end }}
{{- end -}}
