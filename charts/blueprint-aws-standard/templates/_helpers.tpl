{{/*
blueprint-aws-standard: shared template helpers
*/}}

{{- define "blueprint.runtimeId" -}}
{{- coalesce .Values.runtime.id .Values.cluster.name .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "blueprint.rootAppName" -}}
{{- printf "root-%s" (include "blueprint.runtimeId" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "blueprint.fullname" -}}
{{- include "blueprint.runtimeId" . -}}
{{- end -}}

{{- define "blueprint.argoLabels" -}}
app.kubernetes.io/managed-by: argocd
app.kubernetes.io/part-of: {{ include "blueprint.rootAppName" . }}
app.kubernetes.io/instance: {{ include "blueprint.runtimeId" . }}
jetscale.ai/runtime-id: {{ include "blueprint.runtimeId" . }}
jetscale.ai/runtime-cluster: {{ .Values.cluster.name | quote }}
jetscale.ai/provider: {{ default "unknown" .Values.runtime.provider | quote }}
jetscale.ai/environment: {{ default "unknown" .Values.runtime.environment | quote }}
jetscale.ai/client: {{ default "unknown" .Values.runtime.client | quote }}
{{- end -}}
