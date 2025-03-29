.. _crictl_sidecar_debug_container:

=======================================
通过crictl运行一个容器sidecar进行debug
=======================================

我在排查 :ref:`coredns_context_deadline_exceeded` 监控采集异常时，想要进入容器内部验证 :ref:`metrics` 是否已经启用。但是我发现有一个棘手的问题， :ref:`coredns` 容器没有提供任何排查工具，没有提供 :ref:`shell` ，就无法通过 ``kubectl exec`` 或者 ``nsenter`` 进入容器内部排查。

有一个思路是采用 :ref:`crictl` 的 :ref:`crictl_run_pod_sandbox` 功能，借鉴 `How to get into CoreDNS pod kuberrnetes? <https://stackoverflow.com/questions/60666170/how-to-get-into-coredns-pod-kuberrnetes>`_ (原文使用 :ref:`docker` ):

- 创建 ``container-config.json`` :

.. literalinclude:: crictl_sidecar_debug_container/container-config.json
   :language: json
   :caption: ``container-config.json`` 配置运行容器镜像

- 检查 :ref:`coredns` 的容器ID:

.. literalinclude:: crictl/crictl_ps
   :language: bash
   :caption: 通过 ``crictl ps`` 获取coredns的容器ID

在输出中找出coredns对应 pod ID 是 ``47933c32ce14d``  :

.. literalinclude:: crictl/crictl_ps_output
   :language: bash
   :caption: 通过 ``crictl ps`` 获取coredns的容器ID输出信息
   :emphasize-lines: 4

- 我们需要在coredns的pod ``47933c32ce14d`` 再运行一个用于调试的sidecar，所以构建一个 ``pod-config.json`` 来对应:

.. literalinclude:: crictl_sidecar_debug_container/pod-config.json
   :language: json
   :caption: ``pod-config.json`` 配置运行coredns的pod

- 运行起容器加入到现有的 coredns pods中:

.. literalinclude:: crictl_sidecar_debug_container/crictl_run_container_inside_sandbox
   :language: bash
   :caption: 通过 ``crictl run`` 在sandbox中运行新容器

.. warning::

   我这个思路还没实现成功，还需要进一步学习实践

   我忽然想到，另一种方式是通过 ``kubectl edit`` 为pods增加一个 :ref:`sidecar` 或许是更为优雅的方法

参考
=======

- `How to get into CoreDNS pod kuberrnetes? <https://stackoverflow.com/questions/60666170/how-to-get-into-coredns-pod-kuberrnetes>`_
