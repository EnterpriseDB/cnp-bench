# Benchmarking Cloud Native PostgreSQL

`cnp-bench` provides a set of guidelines for benchmarking
[Cloud Native PostgreSQL (CNP)](https://docs.enterprisedb.io/) by
[EDB](https://enterprisedb.com/) in a controlled environment, prior to
the deployment of the database in production.
Cloud Native PostgreSQL is a Kubernetes operator for
[PostgreSQL](https://www.postgresql.org/) and
[EDB Postgres Advanced](https://www.enterprisedb.com/products/edb-postgres-advanced-server-secure-ha-oracle-compatible).

**IMPORTANT:** `cnp-bench` must be run in a staging or pre-production
environment. Do not use `cnp-bench` in a production environment, as it
might have catastrophic consequences on your databases and the other
workloads/applications that run in the same shared environment.

Benchmarking is focused on two aspects:

- the storage, which is one of the most critical component for PostgreSQL, by relying on `fio`
- the database itself, by relying on `pgbench`, PostgreSQL's default benchmarking application

`cnp-bench` comprises Helm charts for common benchmarking scenarios:

* Running fio inside Kubernetes on a user-defined storage class;
* Setting up an user-defined CNP cluster and running a pgbench job on it;
* Setting up a CNP cluster and exposing it via a LoadBalancer, to allow
  testing CNP from an external location (for example a VM outside Kubernetes).

## Requirements

* A running Kubernetes cluster;
* A working connection to the cluster via `kubectl`;
* The Cloud Native PostgreSQL operator must already be installed on the cluster, manifests are
  available at [get.enterprisedb.io](https://get.enterprisedb.io/cnp/)
  and can be installed running:

  ``` sh
  kubectl apply -f https://get.enterprisedb.io/cnp/postgresql-operator-VERSION.yaml
  ```

* Helm should be installed locally, see the
  ["Installing Helm" documentation page](https://helm.sh/docs/intro/install/).

## Installing the Helm charts

Clone the repository:

```
git clone git@github.com:EnterpriseDB/cnp-bench.git
cd cnp-bench
```

You can install a chart by defining a "Release Name" that will be used to
identify the resources and running:

``` sh
helm install RELEASE_NAME path/to/chart/dir
```

You can override the default settings included in the `values.yaml` file of a
chart using the `--values` or `--set` options of `helm install`.
More details are available in the
[Helm install documentation](https://helm.sh/docs/helm/helm_install/#helm-install).
See the `README.md` file included in each chart for the available parameters.

Resources created by a chart can be removed running:

``` sh
helm uninstall RELEASE_NAME
```

## fio benchmark

The chart is contained in the `fio-benchmark` directory.

It will:

1. Create a PVC;
1. Create a ConfigMap representing the configuration of a fio job;
1. Create a fio deployment composed by a single Pod, which will run fio on
   the PVC, create graphs after completing the benchmark and start serving the
   generated files with a webserver. We use the
   [`fio-tools`](https://github.com/wallnerryan/fio-tools`) image for that.

The pod created by the deployment will be ready when it starts serving the
results. You can forward the port of the pod created by the deployment

```
kubectl port-forward -n NAMESPACE deployment/RELEASE_NAME 8000
```

and then use a browser and connect to `http://localhost:8000/` to get the data.

The default 8k block size has been chosen to emulate a PostgreSQL workload.
Disk that cap the amount of available IOPS can show very different throughput
values changing this parameter.

## pgbench

[pgbench](https://www.postgresql.org/docs/current/pgbench.html) is the default
benchmarking application for PostgreSQL. The chart for `pgbench` is contained
in the `pgbench-benchmark` directory.

It will:

1. Create a CNP cluster based on the user-defined values;
1. Execute a used-defined pgbench job on it.

You can gather the results after the job is completed running:

``` sh
kubectl logs -n NAMESPACE job/RELEASE_NAME-pgbench
```

You can use the `kubectl wait` command to wait until the job is complete:

``` sh
kubectl wait --for=condition=complete -n NAMESPACE job/RELEASE_NAME-pgbench
```

It is suggested to label nodes and use node selectors to avoid pgbench and
PostgreSQL pods running on the same node. By default, the chart expects
the nodes on which pgbench can run to be labelled with `workload: pgbench`
and the node for CNP instances to be labelled with `workload: postgresql`.

``` sh
kubectl label node/NODE_NAME workload:pgbench
kubectl label node/OTHER_NODE_NAME workload:postgresql
```

## CNP with LoadBalancer

The chart is contained in the `cnp-loadbalancer` directory.

No benchmark is run in this scenario. We just create a CNP cluster and expose
its primary via a LoadBalancer. The idea is allowing an external application
to run any kind of benchmark on the underlying PostgreSQL instance.

The chart will:

1. Create a CNP cluster based on the user-defined values;
1. Expose the primary using a LoadBalancer.

You can get the password used by the `app` user to connect to the `app` database
running:

``` sh
kubectl get secrets -n NAMESPACE RESOURCE_NAME-app -o jsonpath='{.data.password}' | tr -d '\n' | base64 -d
```

You get also get a `.pgpass` file with:

``` sh
kubectl get secrets -n NAMESPACE RESOURCE_NAME-app -o jsonpath='{.data.pgpass}' | tr -d '\n' | base64 -d
```

You can find The IP of the LoadBalancer exposing PostgreSQL with:

``` sh
kubectl get services -n NAMESPACE RESOURCE_NAME -o jsonpath='{.status.loadBalancer.ingress[].ip}'
```

## Contributing

Please read the [code of conduct](CODE-OF-CONDUCT.md) and the
[guidelines](CONTRIBUTING.md) to contribute to the project.

## Disclaimer

`cnp-bench` is open source software and comes "as is". Please carefully
read the [license](LICENSE) before you use this software, in particular
the "Disclaimer of Warranty" and "Limitation of Liability" items.

*Benchmarking is an activity that must be done before you deploy a system
in production. Do not run `cnp-bench` in a production environment, unless
you are aware of the impact of this operation with other services that
are hosted on the same environment.*

## Copyright

`cnp-bench` is distributed under Apache License 2.0.

Copyright (C) 2021 EnterpriseDB Corporation.
