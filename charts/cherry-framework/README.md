# Zeebe Cherry Framework 7 Helm Chart

A Helm chart for Zeebe Cherry Framework, the open-source zeebe worker framework.

> **Note**
>
> This chart is a community effort for **Zeebe Cherry framework**

## Install

<!--
# TODO: publish helm chart
$ helm repo add camunda https://helm.cch.camunda.cloud
$ helm repo update
$ helm install cherry-demo camunda/zeebe-cherry-framework
 -->

```sh
$ cd to the zeebe-cherry-framework-helm directory
$ helm install demo charts/cherry-framework
```

Alternate use Kind in Kubernetes. Use Make to install the zeebe cherry framework for you in kind.
> **Note**
> You will need to install Make and Kind.
> You can find the [Makefile here](https://github.com/camunda-community-hub/zeebe-cherry-framework-helm/blob/main/Makefile)

```sh
$ cd to the zeebe-cherry-framework-helm directory
$ make
```



## Links

* Camunda homepage: https://camunda.com
* Camunda BPM Platform repo: https://github.com/camunda/camunda-bpm-platform
* Camunda BPM Platform Docker image: https://github.com/camunda/docker-camunda-bpm-platform
* Zeebe Cherry Framework: https://github.com/camunda-community-hub/zeebe-cherry-framework

## Example

Using this custom values file the chart will:
* Use a custom name for deployment.
* Deploy instances of [Zeebe Cherry Framework]()
  with `Webapp` enabled.
<!-- * Use PostgreSQL as an external database (it assumes that the database `process-engine` is already created
  and the secret `postgresql-credentials` has the mandatory data `DB_USERNAME` and `DB_PASSWORD`).
* Set custom config for `readinessProbe` and checking an endpoint that queries the database
  so no traffic will be sent to the REST API if the engine pod is not able to access the database.
* Expose Prometheus metrics of the Zeebe Cherry framework over the metrics service with port `9404`. -->

```yaml
# Custom values.yaml

general:
  fullnameOverride: zeebe-cherry-framework
  replicaCount: 3

image:
  name: ghcr.io/camunda-community-hub/zeebe-cherry-framework
  tag: latest
  command: ['']
  args: ['']

extraEnvs:
- name: DB_VALIDATE_ON_BORROW
  value: "false"

database:
  driver: org.postgresql.Driver
  url: jdbc:postgresql://zeebe-cherry-framework-postgresql:5432/process-engine
  credentialsSecretName: zeebe-cherry-framework-postgresql-credentials
  credentialsSecretEnabled: true

service:
  type: ClusterIP
  port: 8080
  portName: http

readinessProbe:
  enabled: true
  config:
    httpGet:
      path: /cherry
      port: http
    initialDelaySeconds: 120
    periodSeconds: 60

metrics:
  enabled: true
  service:
    type: ClusterIP
    port: 9404
    portName: metrics
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/path: "/"
      prometheus.io/port: "9404"
```

## Configuration

### General

#### Replicas
Set the number of replicas:
```yaml
general:
  replicaCount: 1
```

#### Extra environment variables

The deployment could be customized by providing extra environment variables according to the project
[Docker image](https://github.com/camunda-community-hub/zeebe-cherry-framework). The extra environment variables will be templated using the ['tpl' function](https://helm.sh/docs/howto/charts_tips_and_tricks/#using-the-tpl-function). This is useful to pass a template string as a value to a chart or render external configuration files.

```yaml
extraEnvs:
- name: DB_VALIDATE_ON_BORROW
  value: "false"
- name: SERVICE_PORT
  value: {{ .Values.service.port }}
```

#### Debugging
Enable debugging in the zeebe-cherry-framework container by setting:
```yaml
general:
  debug: true
```

### Init Containers

For a reason or another, you could need to do some pre-startup actions before the start of the zeebe-cherry-framework.
e.g. you could wait for a specific service to be ready or to post to an external service.

If that's needed, it could be done as the following:

```yaml
initContainers:
- name: pre-startup-checks
  image: busybox:1.28
  command: ['sh', '-c', 'echo "The initContainers work as expected"']
```

### Extra Containers

For a reason or another, you could need to add sidecars.
e.g. you could have a fluentd that check your logs or a vault that inject your db secrets.

If that's needed, it could be done as the following:

```yaml
extraContainers:
- name: fluentd
  image: "fluentd"
  volumeMounts:
    - mountPath: /my_mounts/cribl-config
      name: config-storage
```

### Image

Zeebe Cherry Framework open-source [Docker image is here](https://github.com/camunda-community-hub/zeebe-cherry-framework/pkgs/container/zeebe-cherry-framework)
check the list of
[supported tags/releases](https://github.com/camunda-community-hub/zeebe-cherry-framework/releases)
by Zeebe Cherry Framework docker project for more details.

The image used in the chart is `latest`.

### Database

One of the [supported databases](https://docs.camunda.org/manual/latest/introduction/supported-environments/#databases)
could be used as a database for Zeebe Cherry Framework.

The H2 database is used by default which works fine if you just want to test Zeebe Cherry Framework 7.
But since the database is embedded, only 1 deployment replica could be used.

For real-world workloads, an external database like PostgreSQL should be used.
The following is an example of using PostgreSQL as an external database.

First, assuming that you have a PostgreSQL system up and running with service and port
`zeebe-cherry-framework-postgresql:5432`, create a secret has database credentials which will be used later zeebe-cherry-framwork

```sh
$ kubectl create secret generic                 \
    postgresql-credentials \
    --from-literal=DB_USERNAME=foo              \
    --from-literal=DB_PASSWORD=bar
```

Now, set the values to use the external database:

```yaml
database:
  driver: org.postgresql.Driver
  url: jdbc:postgresql://zeebe-cherry-framework-postgresql:5432/process-engine
  credentialsSecretName: postgresql-credentials
  credentialsSecretEnabled: true
  # The username and password keys could be customized to whatever used in the credentials secret.
  credentialsSecretKeys:
    username: DB_USERNAME
    password: DB_PASSWORD
```

**Please note**, this Helm chart doesn't manage any external database, it just uses what's configured.

### Metrics

Enable Prometheus metrics for Zeebe Cherry Framework 7 by setting the following in the values file:

```yaml
metrics:
  enabled: true
  service:
    type: ClusterIP
    port: 9404
    portName: metrics
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/path: "/"
      prometheus.io/port: "9404"
```

If there is a Prometheus configured in the cluster, it will scrap the metrics service automatically.
Check the notes after the deployment for more details about the metrics endpoint.
