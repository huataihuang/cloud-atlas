.. _quick_config_ipmi:

=================
快速配置IPMI
=================

.. note::

   2025年初，将损坏的 :ref:`hpe_dl360_gen9` 升级到 :ref:`hpe_dl380_gen9` ，重新配置IPMI。本文为设置笔记兼快速起步手册。综合了 :ref:`use_ipmi` 的学习笔记和实践经验。

- 检查当前配置(购买到的二手 :ref:`hpe_dl380_gen9` )

.. literalinclude:: quick_config_ipmi/ipmi_lan_print
   :caption: ``ipmitool lan print`` 输出 ``channel 2``

输出显示:

.. literalinclude:: quick_config_ipmi/ipmi_lan_print_output
   :caption: ``ipmitool lan print`` 输出 ``channel 2`` 内容

上述是拿到手时候二手服务器初始状态，也就是默认没有配置的出厂状态

- 检查当前系统中已经具备账号:

.. literalinclude:: quick_config_ipmi/ipmi_user_list
   :caption: 当前系统中已经具备账号

可以看到有2个账号 ``Administrator`` 和 ``root``

- ``Administrator`` 账号名字太长了，修改成 ``admin`` :

.. literalinclude:: quick_config_ipmi/ipmi_user_set_name
   :caption: 将 ``Administrator`` 改名成 ``admin``

- 将 ``admin`` 和 ``root`` 账号都设置密码:

.. literalinclude:: quick_config_ipmi/ipmi_user_set_password
   :caption: 设置账号密码

- 当前只有2个账号，假设设置第3个账号 ``huatai`` ，然后为这个账号设置密码并设置能够远程管理服务器:

.. literalinclude:: quick_config_ipmi/ipmi_user_set
   :caption: 创建账号并设置权限

.. note::

   详细说明见 :ref:`use_ipmi`

- 配置一个 ``monitor`` 账号赋予较低权限以便能够监控传感器，后续会使用这个账号部署监控ipmi:

.. literalinclude:: quick_config_ipmi/ipmi_user_monitor
   :caption: 配置 ``monitor`` 账号

- 最后配置一个IPMI网络，这样就可以远程管理:

.. literalinclude:: quick_config_ipmi/ipmi_network
   :caption: 配置远程管理网络
