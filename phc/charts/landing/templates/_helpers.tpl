{{/*
Expand the name of the chart.
*/}}
{{- define "landing.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "landing.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "landing.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "landing.labels" -}}
helm.sh/chart: {{ include "landing.chart" . }}
{{ include "landing.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "landing.selectorLabels" -}}
app.kubernetes.io/name: {{ include "landing.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "landing.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "landing.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the environments variable
*/}}
{{- define "landing.environments" -}}
- name: APP_VERSION
  value: {{ .Values.image.tag | quote }}
- name: NUXT_PUBLIC_APP_VERSION
  value: {{ .Values.image.tag | quote }}
# *****************************
- name: NUXT_PUBLIC_API_BASE_URL
  value: {{ .Values.environments.nuxt.public.apiBaseUrl | quote }}
# *****************************
# Site Information
# *****************************
- name: NUXT_PUBLIC_PANEL_URL
  value: {{ .Values.environments.nuxt.public.panelUrl | default "https://panel.phc.w3x.app" | quote }}
# *****************************
# Security Services
# *****************************
- name: NUXT_PUBLIC_ALTCHA_CHALLENGE_URL
  value: {{ .Values.environments.nuxt.public.altcha.challengeUrl | default "https://api.phc.w3x.app/challenge" | quote }}
# *****************************
# Client Information
# *****************************
- name: NUXT_PUBLIC_APP_ID
  value: {{ .Values.environments.nuxt.public.appId | quote }}
- name: NUXT_PUBLIC_CLIENT_ID
  value: {{ .Values.environments.nuxt.public.clientId | quote }}
# *****************************
# Logging Services
# *****************************
- name: SENTRY_URL
  value: {{ .Values.environments.nuxt.public.sentry.url | quote }}
- name: SENTRY_AUTH_TOKEN
  value: {{ .Values.environments.nuxt.public.sentry.authToken | quote }}
- name: NUXT_PUBLIC_SENTRY_DSN
  value: {{ .Values.environments.nuxt.public.sentry.dsn | quote }}
- name: NUXT_PUBLIC_SENTRY_TRACES_SAMPLE_RATE
  value: {{ .Values.environments.nuxt.public.sentry.tracesSampleRate | default "0.1" | quote }}
# *****************************
# OSM Services
# *****************************
- name: NUXT_PUBLIC_MAPTILE_SERVER_PATH
  value: {{ .Values.environments.nuxt.public.mapTileServerPath | default "https://tile.openstreetmap.org/{z}/{x}/{y}.png" | quote }}
{{- end }}
