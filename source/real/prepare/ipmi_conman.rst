.. _ipmi_conman:

==========================
IPMI结合conman维护服务器
==========================

:ref:`priv_cloud_infra` 是我采用 :ref:`hpe_dl360_gen9` 二手服务器构建的云计算模拟环境。对于服务器系统， :ref:`use_ipmi` 结合 :ref:`conman` ，可以构建出大规模集群物理服务器带外管理系统。

IPMI配置
============

首先，物理服务器要开启IPMI并进行基础配置:

- 带外管理IP:

.. literalinclude:: ../../linux/server/ipmi/use_ipmi/config_ipmi_addr
   :language: bash
   :caption: 配置IPMI网络

- 创建admin管理账号:

.. literalinclude:: ../../linux/server/ipmi/use_ipmi/config_ipmi_admin
   :language: bash
   :caption: 配置IPMI的admin账号

- 现在可以验证通过网络访问IPMI控制台:

.. literalinclude:: ../../linux/server/ipmi/use_ipmi/ipmi_sol_activate
   :language: bash
   :caption: 通过IPMI访问控制台

- 获取系统日志:

.. literalinclude:: ../../linux/server/ipmi/use_ipmi/ipmi_sel_list
   :language: bash
   :caption: 通过IPMI获取系统日志

- 重BMC:

.. literalinclude:: ../../linux/server/ipmi/use_ipmi/ipmi_mc_reset
   :language: bash
   :caption: 重启BMC

- 重启服务器:

.. literalinclude:: ../../linux/server/ipmi/use_ipmi/ipmi_power_reset
   :language: bash
   :caption: 重启服务器
