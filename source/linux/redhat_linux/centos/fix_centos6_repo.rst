.. _fix_centos6_repo:

==============================
修复CentOS 6软件仓库配置
==============================

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

- 然后做一次系统更新::

   yum update