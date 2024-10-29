.. _docker_kernel_bridge-nf-call-iptables:

============================================================
``docker info`` 显示 ``bridge-nf-call-iptables`` 禁用的处理
============================================================

在 :ref:`install_docker_raspberry_pi_os` 完成后(实际上很多 :ref:`install_docker_linux` 都会遇到)，执行 ``docker info`` 检查会看到如下警告:

.. literalinclude:: docker_kernel_bridge-nf-call-iptables/warning_bridge-nf-call-iptables
   :caption: ``docker info`` 显示 ``bridge-nf-call-iptables`` 被禁止的警告

这个警告实际上是 **预期特性** :

- ``bridge-nf-call-iptables`` 内核参数控制穿过网桥 ``bridge`` 的数据包是否由host主机系统上的 :ref:`iptables` 规则处理。通常不建议启用这个选项:

  - **启用** ``bridge-nf-call-iptables`` 内核参数( ``1`` ) ``可能`` 会导致 **容器流量** 被针对host主机的iptables规则阻止(出现不可预测的行为，通常容器不希望流量收到主机级别防火墙干扰/保护)

  - 这也是为何 :ref:`libvirt_bridged_network` 要求 **禁止** ``bridge-nf-call-iptables`` 内核参数( ``0`` )，否则可能因为host主机配置了iptables防火墙(默认netfilter激活在bridge上会通过FORWARD规则过滤掉bridge上主机之间流量)，导致bridge模式连接到 ``br0`` 的虚拟机之间网络不能互通

.. literalinclude:: ../../../kvm/libvirt/network/libvirt_bridged_network/sysctl_bridge
   :language: bash
   :caption: /etc/sysctl.d/bridge.conf 禁止bridge设备的netfilter

- 在 :ref:`kvm` / :ref:`libvirt` 环境中，要求 **禁止** ``bridge-nf-call-iptables`` 内核参数( ``0`` )，是因为希望在虚拟机内部管理网络过滤，防止host主机iptables ``FORWARD`` 影响虚拟机 :ref:`libvirt_bridged_network`

- 在 :ref:`docker` 容器环境中，要求 **启用** ``bridge-nf-call-iptables`` 内核参数( ``1`` )，是因为容器内部不能通过 ``iptables`` 控制内核过滤规则，需要借助host主机iptables来管理容器网络。

Docker环境启用 ``bridge-nf-call-iptables`` (内核参数  ``1`` )
==============================================================

和 :ref:`libvirt_bridged_network` 配置相反(方法可借鉴)，执行以下命令为Docker的host主机启用 ``bridge-nf-call-iptables`` (内核参数  ``1`` ):

.. literalinclude:: docker_kernel_bridge-nf-call-iptables/sysctl_bridge-nf-call-iptables_1
   :caption: 启用 ``bridge-nf-call-iptables`` (内核参数  ``1`` )

.. _br_netfilter:

``br_netfilter`` 内核模块(提供 ``bridge-nf-call-iptables`` 入口)
====================================================================

我在 :ref:`pi_5` 上的 :ref:`raspberry_pi_os` 遇到如下报错:

.. literalinclude:: docker_kernel_bridge-nf-call-iptables/bridge-nf-call-iptables_error
   :caption: ARM架构的 :ref:`raspberry_pi_os` 提示报错显示没有 ``bridge-nf-call-iptables`` 内核参数入口

这个内核入口错误是因为内核没有加载 ``br_netfilter`` 模块导致的，所以修正如下:

.. literalinclude:: docker_kernel_bridge-nf-call-iptables/modprobe_br_netfilter
   :caption: 加载 ``br_netfilter`` 内核模块

参考
==========

- `Oracle Container Runtime for Docker User's Guide >> Known Issues <https://docs.oracle.com/en/operating-systems/oracle-linux/docker/docker-KnownIssues.html>`_
- `GitHub: iamcryptoki/fix-sysctl.txt <https://gist.github.com/iamcryptoki/ed6925ce95f047673e7709f23e0b9939>`_
- `Ansible: Failed to reload sysctl: sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables: No such file or directory <https://stackoverflow.com/questions/54059636/ansible-failed-to-reload-sysctl-sysctl-cannot-stat-proc-sys-net-bridge-bridg>`_

