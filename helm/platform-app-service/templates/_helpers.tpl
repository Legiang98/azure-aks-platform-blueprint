{{- define "platform-app-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "platform-app-service.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "platform-app-service.name" . -}}
{{- end -}}
{{- end -}}

{{- define "platform-app-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "platform-app-service.fullname" . -}}
{{- end -}}
{{- end -}}

{{- define "platform-app-service.labels" -}}
app.kubernetes.io/name: {{ include "platform-app-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- with .Values.platform.tenant }}
tenant: {{ . | quote }}
{{- end }}
{{- with .Values.platform.app }}
app: {{ . | quote }}
{{- end }}
{{- with .Values.platform.environment }}
environment: {{ . | quote }}
{{- end }}
{{- end -}}

{{- define "platform-app-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "platform-app-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
