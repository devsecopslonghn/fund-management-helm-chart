{{- define "fund-management-frontend.labels" -}}
app.kubernetes.io/name: fund-management
app.kubernetes.io/component: frontend
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
