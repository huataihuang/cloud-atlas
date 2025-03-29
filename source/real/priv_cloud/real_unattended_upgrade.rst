.. _real_unattended_upgrade:

========================
真实(模拟)自动系统更新
========================

我在部署 :ref:`priv_cloud_infra` 和 :ref:`edge_cloud_infra` 这样的模拟环境中，部署了大量的虚拟机，主要有:

- :ref:`ubuntu_linux`
- :ref:`fedora`
- :ref:`alpine_linux`

由于都是测试环境，相对来说稳定性要求不如生产环境；同时大量的虚拟机依靠人力来维护升级非常麻烦，所以我在整个 :ref:`priv_cloud_infra` 和 :ref:`edge_cloud_infra` 环境中部署启用 ``自动系统更新``

:ref:`ubuntu_linux`
======================

:ref:`ubuntu_unattended_upgrade` 采用如下步骤

- 安装 ``unattended-upgrades`` 软件包:

.. literalinclude:: ../../linux/ubuntu_linux/admin/ubuntu_unattended_upgrade/apt_install_unattended-upgrades
   :language: bash
   :caption: 使用apt命令安装unattended-upgrades软件包

- 生成 ``/etc/apt/apt.conf.d/20auto-upgrades`` 配置:

.. literalinclude:: ../../linux/ubuntu_linux/admin/ubuntu_unattended_upgrade/enable_unattended-upgrades
   :language: bash
   :caption: 命令行激活unattended-upgrades

:ref:`fedora`
====================

:ref:`fedora_autoupdates` 使用 ``dnf-automatic`` :

- 安装 ``dnf-automatic`` :

.. literalinclude:: ../../linux/redhat_linux/fedora/fedora_autoupdates/dnf_install_dnf-automatic
   :language: bash
   :caption: 在Fedora系统中安装dnf-automatic


- 修订 ``/etc/dnf/automatic.conf`` :

.. literalinclude:: ../../linux/redhat_linux/fedora/fedora_autoupdates/enable_dnf-automatic_apply
   :language: bash
   :caption: 激活dnf-automatic自动安装补丁

- 运行并激活 :ref:`systemd` 的 ``dnf-automatic.timer`` 定时器:

.. literalinclude:: ../../linux/redhat_linux/fedora/fedora_autoupdates/enable_systemd_dnf-automatic.timer
   :language: bash
   :caption: 运行并激活dnf-automatic.timer
