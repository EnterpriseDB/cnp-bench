{{/*
Expand the name of the chart.
*/}}
{{- define "hammerdb-benchmark.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hammerdb-benchmark.fullname" -}}
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
{{- define "hammerdb-benchmark.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hammerdb-benchmark.labels" -}}
helm.sh/chart: {{ include "hammerdb-benchmark.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Service that we should connect to
*/}}
{{- define "hammerdb-benchmark.service" -}}
{{- if .Values.cnp.pooler.instances -}}
pooler-{{ include "hammerdb-benchmark.fullname" . }}
{{- else -}}
{{ include "hammerdb-benchmark.fullname" . }}-rw
{{- end -}}
{{- end}}

{{- define "hammerdb-benchmark.credentials" -}}
{{- if not .Values.cnp.existingCluster }}
- name: PGHOST
  value: {{ include "hammerdb-benchmark.service" . }}
- name: PGUSER
  valueFrom:
    secretKeyRef:
      name: {{ include "hammerdb-benchmark.fullname" . }}-superuser
      key: username
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "hammerdb-benchmark.fullname" . }}-superuser
      key: password
- name: PGSUPERUSER
  valueFrom:
    secretKeyRef:
      name: {{ include "hammerdb-benchmark.fullname" . }}-superuser
      key: username
- name: PGSUPERUSERPASS
  valueFrom:
    secretKeyRef:
      name: {{ include "hammerdb-benchmark.fullname" . }}-superuser
      key: password
{{- else -}}
- name: PGHOST
  value: {{ .Values.cnp.existingHost }}
- name: PGUSER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.cnp.existingSuperuserCredentials }}
      key: username
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.cnp.existingSuperuserCredentials }}
      key: password
- name: PGSUPERUSER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.cnp.existingSuperuserCredentials }}
      key: username
- name: PGSUPERUSERPASS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.cnp.existingSuperuserCredentials }}
      key: password
{{- end -}}
{{- end }}
