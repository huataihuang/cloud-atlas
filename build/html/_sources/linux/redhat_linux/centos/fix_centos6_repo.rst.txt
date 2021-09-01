.. _fix_centos6_repo:

==============================
修复CentOS 6软件仓库配置
==============================

CentOS 6发行版repo修复
========================

由于CentOS已经停止CentOS 6的更新，所有旧版本软件包都归档到 https:://vault.centos.org ，所以需要修改系统 ``/etc/yum.repo.d`` 目录下的配置文件，指定从 https:://vault.centos.org 下载更新，类似如下::

   cp -r /etc/yum.repos.d /etc/yum.repos.d.bak
   cd /etc/yum.repos.d
   sed -i 's/^mirrorlist=/#mirrorlist=/g' *.repo
   sed -i 's/^#baseurl=/baseurl=/g' *.repo
   sed -i 's/http:\/\/mirror.centos.org\/centos/https:\/\/vault.centos.org/g' *.repo
   sed -i 's/$releasever/6.10/g' *.repo

修复后后配置主要修订内容案例如下( 以 ``CentOS-Base.repo`` 为例)::

   [base]
   name=CentOS-6.10 - Base
   #mirrorlist=http://mirrorlist.centos.org/?release=6.10&arch=$basearch&repo=os&infra=$infra
   baseurl=https://vault.centos.org/6.10/os/$basearch/
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
   ...

完整的配置文件如下

- ``CentOS-Base.repo`` :

.. literalinclude:: fix_centos6_repo/CentOS-Base.repo
    :language: bash
    :linenos:
    :caption:

- ``CentOS-Debuginfo.repo`` :

.. literalinclude:: fix_centos6_repo/CentOS-Debuginfo.repo
    :language: bash
    :linenos:
    :caption:

- ``CentOS-Media.repo`` :

.. literalinclude:: fix_centos6_repo/CentOS-Media.repo
    :language: bash
    :linenos:
    :caption:

- ``CentOS-Vault.repo`` :

.. literalinclude:: fix_centos6_repo/CentOS-Vault.repo
        :language: bash
        :linenos:
        :caption: 

- ``CentOS-fasttrack.repo`` :

.. literalinclude:: fix_centos6_repo/CentOS-fasttrack.repo
   :language: bash
   :linenos:
   :caption:

- 然后做一次系统更新::

   yum update

EPEL软件仓库修复
====================

`EPEL <https://fedoraproject.org/wiki/EPEL>`_ 是基于Fedora完全兼容EPEL/CentOS的软件仓库，提供了更多的扩展软件。不过，随着RHEL/CentOS 6产品生命周期终止，官方已经不再直接提供仓库RHEL/CentOS 6安装包。不过，依然从 `EPEL 6归档 <https://archives.fedoraproject.org/pub/archive/epel/6/>`_ 中安装

* 安装EPEL for RHEL/CentOS 6.8::

   rpm -ivh https://archives.fedoraproject.org/pub/archive/epel/6/x86_64/epel-release-6-8.noarch.rpm

* 然后执行更新::

   yum update

参考
========

- `How to fix yum after CentOS 6 went EOL <https://www.getpagespeed.com/server-setup/how-to-fix-yum-after-centos-6-went-eol>`_
- 