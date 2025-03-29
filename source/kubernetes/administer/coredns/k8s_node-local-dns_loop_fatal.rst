.. _k8s_node-local-dns_loop_fatal:

=======================================================
``node-local-dns`` 缓存启动失败: 检测到配置循环
=======================================================

部署 :ref:`docker_run_coredns` 结合 :ref:`k8s_node-local-dns` ，意外发现有个别节点出现 ``nodelocaldns`` 这个 :ref:`daemonset` 启动失败::

   nodelocaldns-hrgjg  0/1  CrashLoopBackOff  0  3h4m  172.21.45.19  i-2ze3cdvwilmetl7kwybi  <none>  <none>

检查日志:

.. literalinclude:: k8s_node-local-dns_loop_fatal/nodelocaldns_log
   :language: bash
   :caption: nodelocaldns 日志检查

输出显示，CoreDNS检测到配置循环，所以无法启动: (忽略 ``ERROR`` ，这个不影响启动 )

.. literalinclude:: k8s_node-local-dns_loop_fatal/nodelocaldns_log_output
   :language: bash
   :caption: nodelocaldns 日志显示存在配置循环而无法启动
   :emphasize-lines: 11

转发循环
=========

根据提示，在CoreDNS官方文档 `CoreDNS Troubleshooting <https://coredns.io/plugins/loop/#troubleshooting>`_ 对于这种常见错误有一个详细说明:

- 当 ``CoreDNS`` 日志中包含 ``Loop ... detected ...`` 就表示 **循环检测插件** 在其中一个上游DNS服务器中检测到无限转发循环。也就是说CoreDNS发现upstream DNS就是它自己
- 无限转发循环是一个致命错误，会导致消耗内存和CPU，直到主机因内存不足挂掉

常见的转发循环原因:

- CoreDNS将请求直接转发给自己，例如回环地址(127.0.0.1, ::1 或  127.0.0.53)
- CoreDNS将请求转发给上游服务器，但是上游服务器又将请求转发回CoreDNS

排查思路是检查整个DNS查询链路，确保没有出现循环；此外，要仔细检查 ``/etc/resolv.conf`` 确保不包含本地地址

kubernetes集群的转发循环
-------------------------

当Kubernetes中的CoreDNS Pod检测到转发循环，CoreDNS Pod就会出现 ``CrashLoopBackOff`` 。这是因为每次CoreDNS检测到循环并退出时，Kubernetes就会尝试重启Pod。

Kubernetes集群中转发循环的常见原因是与主机节点上本地DNS缓存交互(例如 :ref:`systemd_resolved` )。在一些配置中， ``systemd-reolved`` 会将回环地址 ``127.0.0.53`` 作为名字服务器配置在 ``/etc/resolv.conf`` 中。Kubernetes通过Kubelet默认情况下会将这个 ``/etc/resolv.conf`` 文件传递给所有使用默认 ``dnsPolicy`` 的Pod，这样就会导致Pod无法进行DNS查询(也报错 CoreDNS Pod)。此时CoreDNS使用这个 ``/etc/resolv.conf``
作为转发请求的上游服务器，由于这是一个回环地址，CoreDNS最终会把请求转发给自己。

解决方法如下

方法1
~~~~~~~

- 将以下内容添加到 ``kubelet`` 的配置yaml::

   resolvConf: <path-to-your-real-resolv-conf-file>

- 也可以在 ``--resolv-conf`` 运行参数中传递给kubelet

此时传递的 **真实** 的 ``resolv.conf`` 会被 ``kubelet`` 复制到pods内部进行替换

对于 :ref:`systemd_resolved` ，通常 ``/run/systemd/resolv/resolv.conf`` 是真实的 ``resolv.conf`` (具体取决于发行版)

方法2
~~~~~~~

- 关闭host(物理)主机的local DNS cache，这样就会恢复 ``/etc/resolv.conf`` 的真实DNS服务器配置

方法3
~~~~~~

- 修改 ``CoreDNS`` 的 ``Corefile`` ，将配置::

   forward . /etc/resolv.conf

修改成真实的上游DNS服务器IP地址，例如::

   forward . 8.8.8.8

注意，这个方法只修复CoreDNS问题，而kubelet则继续使用 ``resolv.conf`` 来转发到默认dnsPolicy Pods，这样依然存在DNS解析问题


排查
======

``CoreDNS`` 启动时会从主机复制 ``/etc/resolv.conf`` 到容器内部作为配置，同样 ``nodelocaldns`` 也采用了这个机制。根据上述 `CoreDNS Troubleshooting <https://coredns.io/plugins/loop/#troubleshooting>`_ 首先排查物理主机 ``/etc/rsolv.conf`` ，对比发现这个异常节点的 ``resolv.conf`` 特殊

.. literalinclude:: k8s_node-local-dns_loop_fatal/resolv_err.conf
   :language: bash
   :caption: 存在异常物理主机 ``/etc/resolv.conf``

上述配置中 ``169.254.25.10`` 是一个特殊的IP地址，实际上是 ``localip`` (169.254.0.0/16 is link local address 见 `wikipeidia: Local-link address <https://en.wikipedia.org/wiki/Link-local_address>`_ )， ``k8s-dns-node-cache`` 使用这个IP地址作为服务进程的本地IP地址。所以你在每个 ``nodelocaldns`` ds 运行服务器上检查进程可以看到类似::

   root     22126  0.1  0.0 142376 18000 ?        Ssl  11:33   0:29 /node-cache -localip 169.254.25.10 -conf /etc/coredns/Corefile -upstreamsvc coredns

这里不知道谁在物理主机 ``/etc/resolv.conf`` 中添加了这个IP作为域名解析服务器，这导致配置映射进容器后，CoreDNS(nodelocaldns)检查发现upstream DNS server的IP就是自己local IP，形成了DNS解析回环。这样CoreDNS(nodelocaldns)就会拒绝启动。

.. literalinclude:: k8s_node-local-dns_loop_fatal/resolv.conf
   :language: bash
   :caption: 正确的物理主机 ``/etc/resolv.conf``

参考
=====

- `CoreDNS Troubleshooting <https://coredns.io/plugins/loop/#troubleshooting>`_
