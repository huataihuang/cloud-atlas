.. _fix_kind_restart_fail:

========================
修复kind集群重启异常
========================

构建 :ref:`macos_studio` 采用 :ref:`install_docker_macos` 来运行 :ref:`kind_multi_node` ，和之前一样，再次遇到 :ref:`debug_kind_restart_fail` 困难。虽然 `multi-node: Kubernetes cluster does not start after Docker re-assigns node's IP addresses after (Docker) restart #2045 <https://github.com/kubernetes-sigs/kind/issues/2045>`_ 提到kind 0.15.0 解决多管控节点重启后无法重连的问题，但是我所使用的 kind v0.17.0 还是存在同样问题。

问题原因:

- docker每次重启默认动态分配IP地址，不能保证 :ref:`kind` 各个节点重启后获得相同的IP地址
- :ref:`kind` 在设计之初没有考虑持久化运行，通常都是不断重建来模拟各种环境开发，但这也带来的对于复杂环境搭建非常花费时间的问题

检查
========

- 执行以下命令可以获得 ``kind`` 集群当前各个节点的IP:

.. literalinclude:: fix_kind_restart_fail/get_docker_container_ip
   :language: bash
   :caption: 获取docker容器的IP地址

输出显示:

.. literalinclude:: fix_kind_restart_fail/get_docker_container_ip_output
   :language: bash
   :caption: 获取docker容器的IP地址输出信息

可以验证，每次重启docker( :ref:`install_docker_macos` )，docker容器的IP地址(也就是kind集群的node节点)都会变化，这也就是为何 :ref:`kind_multi_node` 重启后无法正常工作的原因。

这里存在一个问题，就是 `multi-node: Kubernetes cluster does not start after Docker re-assigns node's IP addresses after (Docker) restart #2045 <https://github.com/kubernetes-sigs/kind/issues/2045>`_ 已经修复了多管控节点重启之后IP地址重新分配问题，但是解决的思路是采用 `Fix multi-node cluster not working after restarting docker #2671 <https://github.com/kubernetes-sigs/kind/pull/2671>`_ 提供patch方法，将kubeadm的kubeconfig文件有关 ``kube-controller-manager`` 和 ``kube-scheduler`` 的服务器地址改写为loopback地址

可以看到集群能够正常启动，我采用 :ref:`docker_macos_vm` 的 ``nsenter`` 方法进入虚拟机可以查看到 ``top`` 命令显示:

.. literalinclude:: fix_kind_restart_fail/docker_vm_top
   :language: bash
   :caption: 获取docker虚拟机检查top可以看到etcd/apiserver/haproxy等进程公告的IP地址

解决之道
============

`seguidor777/kind_static_ips.sh <https://gist.github.com/seguidor777/5cda274ea9e1083bfb9b989d17c241e8>`_ 提供了一个非常巧妙的脚本，在部署了 ``kind`` 集群之后，执行这个 ``kind_static_ips.sh`` 可以获取dokcer分配给kind集群每个node的IP地址，然后通过 ``docker network connect --ip <node_ip> "kind" <node_name>`` 来实现指定静态IP地址。

我在原作者的脚本基础上做了一些修订:

.. literalinclude:: fix_kind_restart_fail/kind_static_ips.sh
   :language: bash
   :caption: 通过 kind_static_ips.sh 脚本设置kind集群每个node静态IP
   :emphasize-lines: 10,19,48-49

.. note::

   - 原作 ``kind_static_ips.sh`` 是假设采用了 :ref:`kind_local_registry` ，所以脚本中有一个 ``${reg_name}`` 变量，如果你没有采用 :ref:`kind_local_registry` ，需要修改脚本去掉这个变量，否则执行会报错(因为传递给 ``docker stop`` 命令参数是一个空字符串)::

      Error response from daemon: page not found

   - 我将 ``registry`` 也包含到设置固定IP地址列表(第9行)，但是 ``registry`` 有2个网络接口，其中一个接口是连接在 ``kind`` 网络，另一个连接在 ``bridge`` 网络(通外网)，所以在第18行我过滤掉了 ``bridge`` 网络接口的IP地址，只设置 ``kind`` 接口IP

   - 有两个docker container没有属于kubernetes，即 ``registry`` 和 ``haproxy`` ，所以在第48,49行对docker containers数量减2后再对比 ``kubectl get nodes`` 值

   - 脚本执行需要采用较高版本的bash， :ref:`macos` 内置bash语法不兼容，我在 :ref:`macos_studio` 中特意通过 :ref:`homebrew` 安装了最新版本的 ``bash`` ，并修订了原作者脚本开头采用 ``env`` 来搜索到优先的 ``bash`` 版本( ``homebrew`` 安装后会提供更高的优先级，所以就能满足我这里需要较高版本 ``bash`` 的要求 )

参考
======

- `multi-node: Kubernetes cluster does not start after Docker re-assigns node's IP addresses after (Docker) restart #2045 <https://github.com/kubernetes-sigs/kind/issues/2045>`_
- `Fix multi-node cluster not working after restarting docker #2671 <https://github.com/kubernetes-sigs/kind/pull/2671>`_ 提供了patch方法，将kubeadm的kubeconfig文件有关 ``kube-controller-manager`` 和 ``kube-scheduler`` 的服务器地址改写为loopback地址
