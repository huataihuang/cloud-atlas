.. _etcd_config_rule:

=====================
etcd配置规则
=====================

etcd可以通过以下几种方式配置:

- 命令行参数
- 环境变量
- 配置文件

.. warning::

   如果混合上述3种配置方式，则一定要注意以下规则:

   - 命令行参数优先级高于环境变量
   - 如果提供了 ``配置文件`` ，则 **所有命令行参数和环境变量都会忽略**

参考
======

- `etcd Operations guide / Configuration flags <https://etcd.io/docs/v3.5/op-guide/configuration/>`_
