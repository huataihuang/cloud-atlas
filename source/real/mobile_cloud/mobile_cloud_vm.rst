.. _mobile_cloud_vm:

=============================
移动云的虚拟机部署
=============================

底层虚拟机
==============

按照 :ref:`mobile_cloud_infra` ，底层虚拟机运行:

- :ref:`fedora37_installation` (最小化安装)
- :ref:`mobile_cloud_libvirt_network` 配置静态IP地址

更新软件
-----------

- 更新软件并安装 ``systemd-networkd`` (用于配置静态IP)::

   dnf update
   dnf install systemd-networkd

设置主机名和静态IP
-------------------

- 使用 :ref:`hostnamectl` 配置主机名:

.. literalinclude:: mobile_cloud_vm/hostnamectl
   :language: bash
   :caption: 设置mobile cloud的虚拟机主机名

- 使用 :ref:`systemd_networkd_static_ip` :

.. literalinclude:: mobile_cloud_vm/systemd_networkd_mobile_cloud_vm_ip
   :language: bash
   :caption: 使用systemd-networkd配置mobile cloud的虚拟机IP

并切换到 ``systemd-networkd`` 使得静态IP地址生效:

.. literalinclude:: ../../linux/redhat_linux/systemd/systemd_networkd/switch_systemd-networkd
   :language: bash
   :caption: NetworkManager切换到systemd-networkd使静态IP生效

