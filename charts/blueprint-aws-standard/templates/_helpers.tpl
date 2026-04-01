{{/*
blueprint-aws-standard: shared template helpers
*/}}

{{- define "blueprint.fullname" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "blueprint.argoLabels" -}}
app.kubernetes.io/managed-by: argocd
app.kubernetes.io/part-of: {{ include "blueprint.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
