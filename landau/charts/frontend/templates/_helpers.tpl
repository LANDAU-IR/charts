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
# Only what `nuxt.config.ts` → `runtimeConfig.public` reads: Nuxt exposes nothing else, so a name
# shipped here with no key there is dead on arrival, and a key there with no name here cannot be set.
- name: NUXT_PUBLIC_APP_VERSION
  value: {{ .Values.image.tag | quote }}
# *****************************
- name: NUXT_PUBLIC_API_BASE_URL
  value: {{ .Values.environments.nuxt.public.apiBaseUrl | quote }}
- name: NUXT_PUBLIC_PLATFORM_API_BASE_URL
  value: {{ .Values.environments.nuxt.public.platformApiBaseUrl | quote }}
- name: NUXT_PUBLIC_AUTH_DOMAIN
  value: {{ .Values.environments.nuxt.public.authDomain | default "landau.ir" | quote }}
# *****************************
# Push Information
# *****************************
- name: NUXT_PUBLIC_VAPID_PUBLIC_KEY
  value: {{ .Values.environments.nuxt.public.vapidPublicKey | quote }}
# *****************************
# Security Services
# *****************************
- name: NUXT_PUBLIC_ALTCHA_CHALLENGE_URL
  value: {{ .Values.environments.nuxt.public.altcha.challengeUrl | default "https://api.lnd.landau.app/challenge" | quote }}
# MQTT Over WebSocket
- name: NUXT_PUBLIC_MQTT_WS_URL
  value: {{ .Values.environments.nuxt.public.mqttWsUrl | default "ws://emqx.wenex.org/mqtt" | quote }}
{{- with .Values.environments.nuxt.public.pos }}
# *****************************
# Feature Flags
# *****************************
# Must agree with the backend's ORDER_POS_ENABLED, or a button is offered and then refused.
- name: NUXT_PUBLIC_POS_ENABLED
  value: {{ .enabled | quote }}
- name: NUXT_PUBLIC_POS_BRIDGE_URL
  value: {{ .bridgeUrl | quote }}
{{- end }}
# *****************************
# OSM Services
# *****************************
- name: NUXT_PUBLIC_MAPTILE_SERVER_PATH
  value: {{ .Values.environments.nuxt.public.mapTileServerPath | default "https://tile.openstreetmap.org/{z}/{x}/{y}.png" | quote }}
{{- end }}
