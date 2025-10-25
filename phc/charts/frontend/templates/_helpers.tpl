{{/*
Expand the name of the chart.
*/}}
{{- define "frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "frontend.fullname" -}}
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
{{- define "frontend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "frontend.labels" -}}
helm.sh/chart: {{ include "frontend.chart" . }}
{{ include "frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "frontend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "frontend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "frontend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the environments variable
*/}}
{{- define "frontend.environments" -}}
- name: APP_VERSION
  value: {{ .Values.image.tag | quote }}
- name: NUXT_PUBLIC_APP_VERSION
  value: {{ .Values.image.tag | quote }}
# *****************************
- name: NUXT_PUBLIC_API_BASE_URL
  value: {{ .Values.environments.nuxt.public.apiBaseUrl | quote }}
- name: NUXT_PUBLIC_PLATFORM_API_BASE_URL
  value: {{ .Values.environments.nuxt.public.platformApiBaseUrl | quote }}
# *****************************
# Push Information
# *****************************
- name: NUXT_PUBLIC_VAPID_PUBLIC_KEY
  value: {{ .Values.environments.nuxt.public.vapidPublicKey | quote }}
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
# MQTT Over WebSocket
- name: NUXT_PUBLIC_MQTT_WS_URL
  value: {{ .Values.environments.nuxt.public.mqttWsUrl | default "ws://emqx.wenex.org/mqtt" | quote }}
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
{{- if .Values.environments.nuxt.public.google }}
# *****************************
# OAuth Information
# *****************************
# Google
- name: NUXT_PUBLIC_GOOGLE_SCOPE
  value: {{ .Values.environments.nuxt.public.google.client.scope | default "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile" | quote }}
- name: NUXT_PUBLIC_GOOGLE_CLIENT_ID
  value: {{ .Values.environments.nuxt.public.google.client.id | quote }}
- name: NUXT_PUBLIC_GOOGLE_REDIRECT_URI
  value: {{ .Values.environments.nuxt.public.google.client.redirectUri | quote }}
{{- end }}
# *****************************
# OSM Services
# *****************************
- name: NUXT_PUBLIC_MAPTILE_SERVER_PATH
  value: {{ .Values.environments.nuxt.public.mapTileServerPath | default "https://tile.openstreetmap.org/{z}/{x}/{y}.png" | quote }}
{{- end }}
