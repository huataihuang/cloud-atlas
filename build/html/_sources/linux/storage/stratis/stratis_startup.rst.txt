.. _stratis_startup:

=========================
Stratis存储技术快速起步
=========================

.. note::

   Stratis是目前CentOS/RHEL 8特有的存储管理解决方案，尚未移植到其他发行版，属于Red Hat自有的一整套虚拟化解决方案的组件。由于我在 :ref:`hpe_dl360_gen9` 部署 :ref:`ubuntu_linux` 作为底层操作系统，目前很难引入Stratis存储，所以，我改为在嵌套虚拟化中的第一层虚拟化部署 :ref:`ovirt` 来结合Stratis存储。实践工作将稍后进行

安装和激活Statis
===================

CentOS / Red Hat
---------------------

- 安装 ``statis-cli`` 和 ``statisd`` ::

   dnf install stratisd stratis-cli

- 激活服务::

   systemctl enable --now stratisd

 检查服务::

   systemctl status stratisd

arch linux
-------------

.. note::

   arch linux X86_64架构发行版提供了 ``stratis`` 存储软件，我准备后续在 MacBook Pro 2013上采用 ``stratis`` 存储来运行 :ref:`kvm` ( :ref:`docker` 则采用 :ref:`zfs` )

参考
=======

- `Beginners Guide to Stratis local storage management in CentOS/RHEL 8 <https://www.thegeeksearch.com/beginners-guide-to-stratis-local-storage-management-in-centos-rhel-8/>`_
- `CHAPTER 23. MANAGING LAYERED LOCAL STORAGE WITH STRATIS <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_file_systems/managing-layered-local-storage-with-stratis_managing-file-systems>`_
