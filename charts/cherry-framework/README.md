# Zeebe Cherry Framework Helm Chart

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

* [Camunda homepage](https://camunda.com)
* [Camunda Platform repo](https://github.com/camunda/camunda-platform)
* [Camunda Platform HELM](https://helm.camunda.io/)
* [Zeebe Cherry Framework](https://github.com/camunda-community-hub/zeebe-cherry-framework)

### Image

Zeebe Cherry Framework open-source [Docker image is here](https://github.com/camunda-community-hub/zeebe-cherry-framework/pkgs/container/zeebe-cherry-framework)
check the list of
[supported tags/releases](https://github.com/camunda-community-hub/zeebe-cherry-framework/releases)
by Zeebe Cherry Framework docker project for more details.

The image used in the chart is `latest`.
<!--

### Database

One of the [supported databases](https://docs.camunda.org/manual/latest/introduction/supported-environments/#databases)
could be used as a database for Zeebe Cherry Framework.

The H2 database is used by default which works fine if you just want to test Zeebe Cherry Framework.
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

Enable Prometheus metrics for Zeebe Cherry Framework by setting the following in the values file:

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

-->
