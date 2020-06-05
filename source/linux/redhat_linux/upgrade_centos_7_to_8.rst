.. _upgrade_centos_7_to_8:

=========================
升级CentOS 7到CentOS 8
=========================

.. note::

  从CentOS FAQ来看RHEL7升级RHEL8使用了工具leapp，但是这个工具没有移植到CentOS。

   CentOS论坛有 `Upgrade process from CentOS7 <https://www.centos.org/forums/viewtopic.php?t=71745>`_ 讨论，使用的工具 `leapp <https://leapp-to.github.io/gettingstarted#centos-7>`_ 据测试还存在问题。

   Red Hat官方文档 `UPGRADING TO RHEL 8 <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/upgrading_to_rhel_8/index>`_ 有一个文档说明，可以参考学习。

   本文实践是根据第三方文档 `How to Upgrade CentOS 7 to CentOS 8 <https://www.tecmint.com/upgrade-centos-7-to-centos-8/>`_ 完成

准备工作
===============

- 首先需要安装EPEL仓库::

   yum install epel-release -y

- 安装yum-utils工具::

   yum install yum-utils -y

- 解析RPM包::

   yum install rpmconf -y
   rpmconf -a

注意，这里 ``rpmconf -a`` 有一些交互问答，擦用默认选项。

- 清理所有不需要的软件包::

   package-cleanup --leaves
   package-cleanup --orphans

安装dnf
=========

- 需要首先安装CentOS 8的默认包管理器 dnf ::

   yum install dnf -y

- 然后移除yum包管理器::

   dnf -y remove yum yum-metadata-parser
   rm -Rf /etc/yum

升级CentOS 7到CentOS 8
=========================

- 现在执行CentOS 7升级到CentOS 8前需要线升级从::

   dnf upgrade

- 然后安装CentOS 8的release软件包::

   dnf install http://mirrors.163.com/centos/8/BaseOS/x86_64/os/Packages/centos-repos-8.1-1.1911.0.9.el8.x86_64.rpm \
   http://mirrors.163.com/centos/8/BaseOS/x86_64/os/Packages/centos-release-8.1-1.1911.0.9.el8.x86_64.rpm \
   http://mirrors.163.com/centos/8/BaseOS/x86_64/os/Packages/centos-gpg-keys-8.1-1.1911.0.9.el8.noarch.rpm

- 更新EPEL仓库::

   dnf -y upgrade https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

- 在升级了EPEL仓库后，移除所有临时文件::

   dnf clean all

- 删除CentOS 7的旧内核core::

   rpm -e `rpm -q kernel`

- 移除冲突的软件包::

   rpm -e --nodeps sysvinit-tools

- 然后执行CentOS 8升级::

   dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync

- 安装CentOS 8的新Kernel Core::

   dnf -y install kernel-core

   #   dnf install \
   #   http://mirrors.163.com/centos/8/BaseOS/x86_64/os/Packages/kernel-4.18.0-147.8.1.el8_1.x86_64.rpm \
   #   http://mirrors.163.com/centos/8/BaseOS/x86_64/os/Packages/kernel-core-4.18.0-147.8.1.el8_1.x86_64.rpm \
   #   http://mirrors.163.com/centos/8/BaseOS/x86_64/os/Packages/kernel-modules-4.18.0-147.8.1.el8_1.x86_64.rpm

- 最后安装CentOS 8最小化包::

   dnf -y groupupdate "Core" "Minimal Install"

- 现在可以检查CentOS版本信息::

   cat /etc/redhat-release

.. note::

   注意，上述步骤中每一步都需要仔细检查是否正确执行，千万不能跳过失败都步骤，否则会导致升级错乱失败。

参考
======

- `How to Upgrade CentOS 7 to CentOS 8 <https://www.tecmint.com/upgrade-centos-7-to-centos-8/>`_
