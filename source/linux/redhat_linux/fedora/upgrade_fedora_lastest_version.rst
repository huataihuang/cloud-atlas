.. _upgrade_fedora_lastest_version:

===========================
升级Fedora最新发行版本
===========================

.. note::

   Fedora 支持从不同低版本(Fedora 35/34/33) 直接升级到最新的 Fedora 37 ，目前我安装部署的 ``z-dev`` 版本是 Fedora 35，我准备在2022年11月15日，Fedora 37正式发布时做一次全面的版本升级，以体验最新的Linux技术

- 更新所有系统已经安装的软件包:

.. literalinclude:: upgrade_fedora_lastest_version/dnf_refresh_upgrade
   :language: bash
   :caption: 更新操作系统的所有软件包

- 重启操作系统

- 安装/升级 ``dnf-plugin-system-upgrade`` 软件包:

.. literalinclude:: upgrade_fedora_lastest_version/install_dnf-plugin-system-upgrade
   :language: bash
   :caption: 安装 dnf-plugin-system-upgrade

- 下载更新软件包:

.. literalinclude:: upgrade_fedora_lastest_version/download_releasever_37
   :language: bash
   :caption: 下载Fedora 37更新软件包




参考
========

- `Upgrade to Fedora 37 from Fedora 36 using DNF <https://www.if-not-true-then-false.com/2022/upgrade-to-fedora-37-using-dnf/>`_
- `DNF System Upgrade <https://docs.fedoraproject.org/en-US/quick-docs/dnf-system-upgrade/>`_ 官方文档
