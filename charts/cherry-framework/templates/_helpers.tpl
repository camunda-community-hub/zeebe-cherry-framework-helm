{{/*
Expand the name of the chart.
*/}}
{{- define "zeebe-cherry-framework.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zeebe-cherry-framework.fullname" -}}
{{- if .Values.general.fullnameOverride }}
{{- .Values.general.fullnameOverride | trunc 63 | trimSuffix "-" }}
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
{{- define "zeebe-cherry-framework.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "zeebe-cherry-framework.labels" -}}
{{- if .Values.global.labels -}}
{{ toYaml .Values.global.labels }}
{{- end }}
helm.sh/chart: {{ include "zeebe-cherry-framework.chart" . }}
{{ include "zeebe-cherry-framework.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common match labels, which are extended by sub-charts and should be used in matchLabels selectors.
*/}}
{{- define "zeebe-cherry-framework.matchLabels" -}}
{{/*
{{- if .Values.global.labels -}}
{{ toYaml .Values.global.labels }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: zeebe-zeebe-cherry-framework-platform
*/}}
app.kubernetes.io/name: {{ template "zeebe-cherry-framework.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "zeebe-cherry-framework.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zeebe-cherry-framework.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Set imagePullSecrets according the values of global, subchart, or empty.
*/}}
{{- define "zeebe-cherry-framework.imagePullSecrets" -}}
{{- if (.Values.image.pullSecrets) -}}
{{ .Values.image.pullSecrets | toYaml }}
{{- else if (.Values.global.image.pullSecrets) -}}
{{ .Values.global.image.pullSecrets | toYaml }}
{{- else -}}
[]
{{- end -}}
{{- end -}}

{{/*
Keycloak service name should be a max of 20 char since the Keycloak Bitnami Chart is using Wildfly, the node identifier in WildFly is limited to 23 characters.
Furthermore, this allows changing the referenced Keycloak name inside the sub-charts.
Subcharts can't access values from other sub-charts or the parent, global only. This is the reason why we have a global value to specify the Keycloak full name.
*/}}

{{- define "zeebe-cherry-framework.issuerBackendUrl" -}}
    {{- $keycloakRealmPath := "/auth/realms/zeebe-zeebe-cherry-framework" -}}
    {{- if .Values.global.identity.keycloak.url -}}
        {{- include "identity.keycloak.url" . -}}{{- $keycloakRealmPath -}}
    {{- else -}}
        http://{{ include "common.names.dependency.fullname" (dict "chartName" "keycloak" "chartValues" . "context" $) | trunc 20 | trimSuffix "-" }}:80{{ $keycloakRealmPath }}
    {{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "zeebe-cherry-framework.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "zeebe-cherry-framework.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check if H2 database is used
Note that Helm template always retruns string, so this is not really a bool.
*/}}
{{- define "zeebe-cherry-framework.h2DatabaseIsUsed" -}}
{{- if (hasPrefix "jdbc:h2" .Values.database.url) -}}
true
{{- else -}}
false
{{- end }}
{{- end }}

{{/*
Check if the deployment will have volumes
Note that Helm template always retruns string, so this is not really a bool.
*/}}
{{- define "zeebe-cherry-framework.withVolumes" -}}
{{ if or (eq (include "zeebe-cherry-framework.h2DatabaseIsUsed" .) "true") (not (empty .Values.extraVolumeMounts)) (not (empty .Values.extraVolumes)) -}}
true
{{- else -}}
false
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for ingress according to Kubernetes version.
*/}}
{{- define "zeebe-cherry-framework.ingress.apiVersion" -}}
{{- if .Values.ingress.enabled -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.Version -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "<1.19-0" .Capabilities.KubeVersion.Version -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end }}
{{- end }}
{{- end }}
