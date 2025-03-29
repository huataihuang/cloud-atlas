.. _get_k8s_pod_logs:

=======================
获取Kubernetes Pod日志
=======================

在Kubernetes集群排查故障时，需要使用 ``kubectl logs`` 命令来检查pod日志。这里命令是 ``logs`` 而不是 ``log`` 很有意思，意味着对于pod来说，可能会有多个container存在，观察日志实际是观察多个容器的日志。

- 如果pod只包含一个容器，则可以直接使用::

   kubectl logs <pod_name>

- 日志可以只截取最近6小时的日志::

   kubectl logs <pod_name> --since=6h

- 还可以截取pod的最近50行日志::

   kubectl logs <pod_name> --tail=50

- 支持持续观察pod日志(类似 ``tail -f`` )::

   kubectl logs -f <pod_name>

- 在Pods中有多个容器，则需要获取容器日志，需要通过 ``-c`` 参数指定容器::

   kubectl logs <pod_name> -c <container_name>

- 另外，可以通过 ``--previous`` 输出最近一次容器启动后生成的日志::

   kubectl logs <pod_name> -c <container_name> --previous

.. note::

   这里 ``<pod_name>`` 指定pod， ``<container_name>`` 指定该pod中的容器， ``--previous`` 则输出最近一次容器启动后生成的日志。

   对于pod，可以通过 ``describe pod`` 命令来获取pod的event记录，对于排查pod异常会很有帮助

- 可以一次性获取整个pod中所有容器的日志 ``--all-containers`` ::

   kubectl logs <pod_name> --all-containers

- 可以指定 label 来获取一组pod的日志::

   kubectl logs -l label_key=label_value

- 对于namespace，可以整体获得这个namespace中日志信息(非常有用)::

   kubectl get event [--namespace=my-namespace]

部署日志
=============

除了容器内部日志，还可以通过部署日志来判断pod的异常问题::

   kubectl describe deployment deployment_name
   kubectl describe replicaset replicaset_name
   kubectl describe pod

对特定部署可以使用命令::

   kubectl logs deployment/deployment_name

参考
=======

- `How to View Kubernetes Pod Logs Files With Kubectl <https://spacelift.io/blog/kubectl-logs>`_
- `How do I tell when/if/why a container in a kubernetes cluster restarts? <https://serverfault.com/questions/727104/how-do-i-tell-when-if-why-a-container-in-a-kubernetes-cluster-restarts>`_
- `How do I get logs from all pods of a Kubernetes replication controller? <https://stackoverflow.com/questions/33069736/how-do-i-get-logs-from-all-pods-of-a-kubernetes-replication-controller>`_
