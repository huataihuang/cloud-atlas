.. _promql_examples:

=====================
PromQL查询案例
=====================

一些有用的PromQL查询案例
===========================

- 按照每个 namespace 查询pod数量::

   sum by (namespace) (kube_pod_info)

- (没理解)找出CPU overcommit::

   sum(kube_pod_container_resource_limits{resource="cpu"}) - sum(kube_node_status_capacity{resource="cpu"})

- (没理解)内存overcommit::

   sum(kube_pod_container_resource_limits{resource="memory"}) - sum(kube_node_status_capacity{resource="memory"})

- 找出没有正常运行的pods::

   min_over_time(sum by (namespace, pod) (kube_pod_status_phase{phase=~"Pending|Unknown|Failed"})[15m:1m]) > 0

- 找出不断Crash的pods::

   increase(kube_pod_container_status_restarts_total[15m]) > 3

- 找出每个namespace中没有CPU限制的容器数量::

   count by (namespace)(sum by (namespace,pod,container)(kube_pod_container_info{container!=""}) unless sum by (namespace,pod,container)(kube_pod_container_resource_limits{resource="cpu"}))

- 找出系统中出于pending状态的PVC::

   kube_persistentvolumeclaim_status_phase{phase="Pending"}

- 找出不稳定的节点::

   sum(changes(kube_node_status_condition{status="true",condition="Ready"}[15m])) by (node) > 2

- 找出空闲的CPU cores::

   sum((rate(container_cpu_usage_seconds_total{container!="POD",container!=""}[30m]) - on (namespace,pod,container) group_left avg by (namespace,pod,container)(kube_pod_container_resource_requests{resource="cpu"})) * -1 >0)

- 找出空闲的内存::

   sum((container_memory_usage_bytes{container!="POD",container!=""} - on (namespace,pod,container) avg by (namespace,pod,container)(kube_pod_container_resource_requests{resource="memory"})) * -1 >0 ) / (1024*1024*1024)

- 查询节点状态::

   sum(kube_node_status_condition{condition="Ready",status="true"})
   sum(kube_node_status_condition{condition="NotReady",status="true"})
   sum(kube_node_spec_unschedulable) by (node)

参考
=======

- `Prometheus queries: 11 promql examples and tutorial <https://www.airplane.dev/blog/promql-cheat-sheet-with-examples>`_
