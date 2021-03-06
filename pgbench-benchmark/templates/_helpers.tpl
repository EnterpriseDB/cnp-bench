{{/*
Expand the name of the chart.
*/}}
{{- define "pgbench-benchmark.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pgbench-benchmark.fullname" -}}
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
{{- define "pgbench-benchmark.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pgbench-benchmark.labels" -}}
helm.sh/chart: {{ include "pgbench-benchmark.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Service that we should connect to
*/}}
{{- define "pgbench-benchmark.service" -}}
{{- if .Values.cnp.pooler.instances -}}
pooler-{{ include "pgbench-benchmark.fullname" . }}
{{- else -}}
{{ include "pgbench-benchmark.fullname" . }}-rw
{{- end -}}
{{- end}}

{{- define "pgbench-benchmark.credentials" -}}
{{- if not .Values.cnp.existingCluster }}
- name: PGHOST
  value: {{ include "pgbench-benchmark.service" . }}
- name: PGUSER
  valueFrom:
    secretKeyRef:
      name: {{ include "pgbench-benchmark.fullname" . }}-app
      key: username
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "pgbench-benchmark.fullname" . }}-app
      key: password
{{- else -}}
- name: PGHOST
  value: {{ .Values.cnp.existingHost }}
- name: PGDATABASE
  value: {{ .Values.cnp.existingDatabase }}
- name: PGPORT
  value: {{ .Values.cnp.existingPort }}
- name: PGUSER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.cnp.existingCredentials }}
      key: username
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.cnp.existingCredentials }}
      key: password
{{- end -}}
{{- end }}
