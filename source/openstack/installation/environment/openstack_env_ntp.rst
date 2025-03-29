.. _openstack_env_ntp:

============================
OpenStack环境NTP
============================

分布式系统对服务器时间精确性有极高要求，对于OpenStack也同样如此。目前主流发行版已经采用 Chrony 来实现NTP时钟管理。

管控节点
============

- 安装软件包::

   yum install chrony

- 配置 ``/etc/chrony.conf`` 

配置上游NTP服务器::

   server NTP_SERVER iburst

.. note::

   CentOS默认安装配置的 ``/etc/chrony.conf`` 已经配置了 ``x.centos.pool.ntp.org`` ，所以实际上默认无需做任何修改，直接启动服务就可以。

   集群中只需要选择2台NTP服务器就可以满足通常要求，当然你也可以配置更多NTP服务器。在 :ref:`openstack_env_host_network` 中，采用3台物理服务器，实际上可以作为整个集群的基础NTP服务器，不论是虚拟机还是今后扩展的工作节点，都可以指向这些内网NTP服务器。

配置允许局域网其他工作节点将本机作为NTP服务器::

   allow 10.0.0.0/24

- 重启NTP服务，并激活::

   systemctl enable chronyd
   systemctl start chronyd

NTP客户端
================

- 安装软件包::

   yum install chrony

- 配置 chrony.conf ，指向自己的NTP服务器::

   server controller iburst

这里controller是前述NTP服务器的域名或者IP地址，可以多条

- 重启NTP服务，并激活::
   
   systemctl enable chronyd
   systemctl start chronyd

验证NTP同步
==============

- 在管控节点和局域网所有节点执行以下命令验证NTP同步::

   chronyc sources

需要看到输出正确的NTP服务器信息。


