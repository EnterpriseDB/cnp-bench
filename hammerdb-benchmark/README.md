# hammerdb-benchmark

![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart that starts a CNP Cluster and executes a HammerDB job on it.

**Homepage:** <https://github.com/EnterpriseDB/cnp-bench/>

## Source Code

* <https://github.com/EnterpriseDB/cnp-bench/>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cnp.existingCluster | bool | `false` | Whether the benchmark should be run against an existing cluster or a new one has to be created |
| cnp.existingHost | string | `""` | The address of the existing cluster |
| cnp.existingSuperuserCredentials | string | `""` | The name of a Secret of type basic-auth containing the existing cluster credentials for a superuser |
| cnp.image | string | `"quay.io/enterprisedb/postgresql:14.1"` | The PostgreSQL image used by CNP and HammerDB. |
| cnp.instances | int | `1` | The amount of PostgreSQL instances in the CNP Cluster. |
| cnp.monitoring | object | `{"customQueriesConfigMap":[],"customQueriesSecret":[]}` | Configures custom queries for monitoring. The arrays accept a Dictionary made by name: string (resource name), key: string (resource data field containing the queries). Documentation on the accepted values: https://docs.enterprisedb.io/cloud-native-postgresql/latest/monitoring/ |
| cnp.nodeSelector | object | `{"workload":"postgresql"}` | Dictionary of key-value pairs used to define the nodes where the cluster instances can run; used to avoid hammerdb and PostgreSQL running on the same node. |
| cnp.pooler.instances | int | `0` | The number of pooler replicas that receive the connections. If >0 the benchmarks are run with connection pooling |
| cnp.pooler.nodeSelector.workload | string | `"pooler"` |  |
| cnp.pooler.pgbouncer.parameters | object | `{}` | PgBouncer configuration. |
| cnp.pooler.pgbouncer.poolMode | string | `"session"` | The pool mode, accepted values: session, transaction |
| cnp.postgreSQLParameters | object | `{"log_autovacuum_min_duration":"1s","log_checkpoints":"on","log_lock_waits":"on","log_min_duration_statement":"1000","log_statement":"ddl","log_temp_files":"1024","maintenance_work_mem":"128MB","shared_buffers":"512MB"}` | Dictionary of key-value pairs representing PostgreSQL configuration. |
| cnp.storage.size | string | `"1Gi"` | The size of the PVCs used by CNP instances. |
| cnp.storage.storageClass | string | `""` | The storage class used to create PVCs for CNP instances. |
| hammerdb.config.initialize | bool | `true` | Whether pgschemabuild should be run |
| hammerdb.config.pg_prewarm | bool | `true` | Whether we should prewarm all used tables before running `pgrun` and after running `pgschemabuild` |
| hammerdb.config.pgrun | string | `"#!/bin/tclsh\ndbset db pg\ndiset connection pg_host $::env(PGHOST)\ndiset tpcc pg_superuser $::env(PGSUPERUSER)\ndiset tpcc pg_superuserpass $::env(PGSUPERUSERPASS)\ndiset tpcc pg_rampup 0\ndiset tpcc pg_duration 1\ndiset tpcc pg_vacuum true\nprint dict\nvuset logtotemp 1\nloadscript\nprint script\nvuset vu 1\nvucreate\nvurun\nruntimer 1200\nvudestroy\nexit"` |  |
| hammerdb.config.pgschemabuild | string | `"#!/bin/tclsh\nputs \"SETTING CONFIGURATION\"\n\ndbset db pg\ndiset connection pg_host $::env(PGHOST)\ndiset tpcc pg_superuser $::env(PGSUPERUSER)\ndiset tpcc pg_superuserpass $::env(PGSUPERUSERPASS)\n#diset connection pg_port 5432\ndiset tpcc pg_count_ware 8\ndiset tpcc pg_num_vu 2\ndiset tpcc pg_raiseerror true\ndiset tpcc pg_driver timed\nprint dict\nbuildschema\nwaittocomplete"` | The tcl script that will be run to populate the database |
| hammerdb.image | string | `"quay.io/enterprisedb/hammerdb:4.2"` |  |
| hammerdb.nodeSelector | object | `{"workload":"hammerdb"}` | Dictionary of key-value pairs used to define the nodes where the hammerdb pod can run; used to avoid hammerdb and PostgreSQL running on the same node. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
