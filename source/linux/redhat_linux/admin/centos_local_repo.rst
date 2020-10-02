.. _centos_local_repo:

======================
CentOS本地软件仓库
======================

当一次次通过Internet安装和更新CentOS，当运维当服务器越来越多，你一定会有一个强烈的愿望，构建一个本地CentOS软件仓库。这样只要同步一次集中的软件仓库，就可以提供本地局域网所有CentOS服务器更新到相同版本。

.. note::

   本实践是在CentOS 8上完成，使用安装命令是 ``dnf`` ，如果你使用CentOS 7或更低版本，则使用 ``yum`` 代替 ``dnf`` 命令。

CentOS 8包含2个仓库: ``BaseOS`` 和 ``AppStream`` (Application Stream):

- BaseOS是最小化操作系统所需要的软件包
- AppStream则包含其余软件包，依赖和数据库

如果你手边有CentOS 8 DVD安装ISO文件，则可以使用安装光盘的ISO文件快速构建本地安装仓库，方便进行软件安装。

挂载CentOS 8安装ISO文件
========================

- 挂载ISO文件到选定的目录，这里选择 ``/opt`` 目录::

   mount CentOS-8-x86_64-1905-dvd1.iso /opt

创建CentOS本地YUM仓库
=====================

- 在ISO文件挂载的目录下有一个 ``media.repo`` 文件，复制到 ``/etc/yum.repos.d/`` 目录下::

   cp -v /opt/media.repo  /etc/yum.repos.d/centos8.repo

- 修订该文件属性避免被其他用户修改::

   chmod 644 /etc/yum.repos.d/centos8.repo

- 修改该配置文件内容修改如下::

   [InstallMedia-BaseOS]
   name=CentOS Linux 8 - BaseOS
   metadata_expire=-1
   gpgcheck=1
   enabled=1
   baseurl=file:///opt/BaseOS/
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
   
   [InstallMedia-AppStream]
   name=CentOS Linux 8 - AppStream
   metadata_expire=-1
   gpgcheck=1
   enabled=1
   baseurl=file:///opt/AppStream/
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

使用本地仓库
================

- 现在更新DNF/YUM缓存::

   dnf clean all
   # 或者
   yum clean all

- 检查本地软件仓库是否生效::

   dnf repolist
   # 或者
   yum repolist

- 现在就可以安装软件包了，可以看到软件包是本地仓库::

   dnf install <package_name>
   
参考
====

- `How to Set Up a Local Yum/DNF Repository on CentOS 8 <https://www.tecmint.com/create-local-yum-repository-on-centos-8/>`_
