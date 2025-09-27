{{/*
Expand the name of the chart.
*/}}
{{- define "selenium-node-chrome.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "selenium-node-chrome.fullname" -}}
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
{{- define "selenium-node-chrome.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "selenium-node-chrome.labels" -}}
helm.sh/chart: {{ include "selenium-node-chrome.chart" . }}
app: {{ include "selenium-node-chrome.name" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "selenium-node-chrome.selectorLabels" -}}
app: {{ include "selenium-node-chrome.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "selenium-node-chrome.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "selenium-node-chrome.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
