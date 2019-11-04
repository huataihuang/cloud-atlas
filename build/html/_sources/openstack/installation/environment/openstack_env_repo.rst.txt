.. _openstack_env_repo:

============================
OpenStack环境软件仓库
============================

OpenStack通过发行版仓库进行安装，所有节点（包括管控、计算和块存储节点）都需要设置并激活OpenStack软件仓库。

.. warning::

   建议在使用 RDO 软件包(RHEL版本使用RDO进行安装)时候禁止 EPEL 软件仓库，因为 EPEL 更新时会破坏向后兼容性。或者使用 ``yum-versionlock`` 插件锁定软件包版本。由于我使用CentOS，所以忽略这个设置要求。

- CentOS 激活 ``extras`` 仓库来激活OpenStack仓库，CentOS已经默认包括了 ``extras`` 仓库，只需要直接安装OpenStack就可以。

安装对应版本::

   yum install centos-release-openstack-train 

- RHEL 添加OpenStack软件仓库 (注意：这步只适用于RHEL) ::

   subscription-manager repos --enable=rhel-7-server-optional-rpms \
     --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-rh-common-rpms

在RHEL上下载并安装 RDO 仓库RPM包激活OpenStack仓库::

   yum install https://rdoproject.org/repos/rdo-release.rpm


安装最后步骤
==============

- 升级所有节点的软件包::

   yum upgrade

- 安装OpenStack客户端::

   yum install python-openstackclient

- RHEL和CentOS默认激活了 SELinux ，则要安装 ``openstack-selinux`` 软件包来管理OpenStack服务的安全策略::

   yum install openstack-selinux
