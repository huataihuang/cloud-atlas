.. _krew_startup:

=================
Krew快速起步
=================

在完成了 :ref:`install_krew` 之后，可以安装管理各种插件，方便运维:

- 下载插件list:

.. literalinclude:: krew_startup/krew_update
   :caption: 下载krew插件列表

- 探索可用的krew插件:

.. literalinclude:: krew_startup/krew_search
   :caption: 查看krew可用插件

输出类似:

.. literalinclude:: krew_startup/krew_search_output
   :caption: 查看krew可用插件输出案例

- 安装插件:

.. literalinclude:: krew_startup/krew_install_resource-capacity
   :caption: 使用 ``krew`` 安装 ``resource-capacity`` 插件

- 升级插件:

.. literalinclude:: krew_startup/krew_upgrade
   :caption: 使用 ``krew`` 升级安装的插件

- 卸载插件

.. literalinclude:: krew_startup/krew_uninstall
   :caption: 使用 ``krew`` 卸载插件

``resource-capacity``
========================

``resource-capacity`` 是一个非常实用的插件，安装以后就可以直接检查集群的资源分配情况( **注意:只是资源的request和limits配置** )，但是如果要检查集群的实时负载信息，依然需要在集群中部署 :ref:`metrics-server` 才能通过metrics采集进行查询

- 安装插件:

.. literalinclude:: krew_startup/krew_install_resource-capacity
   :caption: 使用 ``krew`` 安装 ``resource-capacity`` 插件

- 使用 ``resource-capacity`` 可以检查节点资源实用:

.. literalinclude:: krew_startup/resource-capacity
   :caption: 使用 ``resource-capacity`` 检查集群的资源使用

输出可以看到各个节点使用情况:

.. literalinclude:: krew_startup/resource-capacity_output
   :caption: 使用 ``resource-capacity`` 检查集群的资源使用输出案例

**注意：默认输出实际上只有配置信息(request和limits)** ，所以如果执行获取实时监控信息会报错，见下文:

- 在集群安装了 :ref:`metrics-server` 之后，就可以使用 ``--util`` 参数获取每个节点的报告:

.. literalinclude:: krew_startup/resource-capacity_util
   :caption: ``resource-capacity`` 提供对当前集群的运行使用状态统计 ``--util``

输出案例如下:

.. literalinclude:: krew_startup/resource-capacity_util_output
   :caption: ``resource-capacity`` 提供对当前集群的运行使用状态统计 ``--util`` 可以观察到节点的使用情况

.. note::

   如果集群没有部署 :ref:`metrics-server` ，则 ``resource-capacity --util`` 会报错::

      Error getting Pod Metrics: the server could not find the requested resource (get pods.metrics.k8s.io)
      For this to work, metrics-server needs to be running in your cluster

- ``--util`` 结合 ``--pods`` 参数可以详细列出集群每个node节点上 ``pod`` 的运行情况:

.. literalinclude:: krew_startup/resource-capacity_util_pods
   :caption: ``resource-capacity`` 结合使用 ``--util --pods`` 可以输出所有节点的上pods的运行负载

输出案例:

.. literalinclude:: krew_startup/resource-capacity_util_pods_output
   :caption: ``resource-capacity`` 结合使用 ``--util --pods`` 可以输出所有节点的上pods的运行负载

排序功能
-----------

``--sort`` 参数提供了一些可以按照某列进行排序的功能::

   cpu.util
   cpu.request
   cpu.limit
   mem.util
   mem.request
   mem.limit
   name

当结合了 ``--util --pods`` 再加上排序是按照物理主机的累计进行排序，然后按照每个主机上的pods使用进行排序

.. literalinclude:: krew_startup/resource-capacity_util_pods_sort
   :caption: ``resource-capacity`` 结合使用 ``--util --pods`` 可以输出所有节点的上pods的运行负载

输出案例:

.. literalinclude:: krew_startup/resource-capacity_util_pods_sort_output
   :caption: ``resource-capacity`` 结合使用 ``--util --pods --sort cpu.util`` 可以输出所有节点的上pods的运行负载

更深层的输出
----------------

我们知道 ``pod`` 可能会包含多个container，例如有 ``sidecar`` , ``istio-proxy`` 等案例，此时我们可以结合 ``--pods --containers`` 让整个输出能够深入到容器级别进行负载分析，这对于集群定位故障非常有用:

.. literalinclude:: krew_startup/resource-capacity_util_pods_containers_sort
   :caption: ``resource-capacity`` 结合使用 ``--pods --containers`` 可以展示出更为细节的每个pods的容器负载情况

输出就可以看到每个pod中详细的容器资源使用(高亮了其中一个pod案例可以看到 ``istio-proxy`` 和 ``domainmapping-webhook`` ):

.. literalinclude:: krew_startup/resource-capacity_util_pods_containers_sort_output
   :caption: ``resource-capacity`` 结合使用 ``--pods --containers`` 输出中可以看到容器负载
   :emphasize-lines: 16,17

按照 ``namespace`` 和 ``label`` 进行过滤
------------------------------------------

- 可以通过 ``-n`` 参数指定 namespace 过滤，例如，这里按照 ``kubeflow`` 的namespace过滤:

.. literalinclude:: krew_startup/resource-capacity_util_namespace_pods_containers_sort
   :caption: ``resource-capacity`` 结合使用 ``-n <namespace> --pods --containers`` 检查指定namespace(这里是 ``kube-system`` )中的资源使用

- 支持以下不同级别labels:

  - ``‐‐pod-labels`` - Pod Level Labels
  - ``‐‐namespace-labels`` - Labels used at the Namespace Level
  - ``‐‐node-labels`` - Labels used at the node level

支持输出格式
--------------

默认输出的是 ``table`` 格式，其他还支持 ``yaml`` 和 ``json`` 格式。命令行使用 ``-o`` 参数支持:

- ``yaml``
- ``json``
- ``table``

参考
======

- `Krew doc: Quickstart <https://krew.sigs.k8s.io/docs/user-guide/quickstart/>`_
- `Get CPU and Memory Usage of NODES and PODS - Kubectl | K8s <https://www.middlewareinventory.com/blog/cpu-memory-usage-nodes-k8s/>`_
