.. _ipmitool_sol_activate:

=======================
ipmitool控制台连接
=======================

密码套件(Cipher Suites)不一致
==============================

在 :ref:`use_ipmi` 时，通过 ``ipmitool`` 可以连接到控制台:

.. literalinclude:: use_ipmi/ipmi_sol_activate
   :language: bash
   :caption: 通过IPMI访问控制台

但是你可能会遇到如下报错:

.. literalinclude:: use_ipmi/ipmi_sol_get_channel_cipher_err
   :language: bash
   :caption: 通过IPMI访问控制台提示获取通道密码套件(Channel Cipher Suites)

这个报错是因为 ``ipmitool`` 版本和服务器端BMC控制器密码机制差异导致的，需要在命令行添加一个 ``-C 3``  参数，将默认密码版本回退到3(之前版本)，也就是

.. literalinclude:: use_ipmi/ipmi_sol_activate_3
   :language: bash
   :caption: 通过IPMI访问控制台使用旧版本chiper suites(3)

这个chiper suites支持其实可以通过检查:

.. literalinclude:: use_ipmi/ipmi_lan_print
   :caption: ``ipmitool lan print`` 输出 ``channel 2``

输出显示支持 chiper suites:

.. literalinclude:: use_ipmi/ipmi_lan_print_output
   :caption: ``ipmitool lan print`` 输出 ``channel 2`` 内容
   :emphasize-lines: 17

控制台无输出
=====================================

我的 :ref:`hpe_dl360_gen9` 在连接了控制台之后( ``sol activate`` ):

.. literalinclude:: use_ipmi/ipmi_sol_activate_3
   :language: bash
   :caption: 通过IPMI访问控制台使用旧版本chiper suites(3)

我最初以为是我的BIOS设置问题(没有启用 ``console redirection`` )，但是实际上并不是，因为我发现当我执行了上述 ``sol activiate`` 指令之后，并没有连接报错，而且我发现服务器重启时，这个会话连接实际上能够输出服务器启动的BIOS信息，这说明控制台正常。而到了 :ref:`ubuntu_linux` 启动的 GRUB 界面时，则没有输出(不显示GRUB选择启动的交互界面)。也就是说，真正的问题是Linux的控制台重定向没有配置

:ref:`ubuntu_serial_console`

参考
=======

- `ipmitool: lanplus: hanging on getting cipher suites <https://www.suse.com/support/kb/doc/?id=000020250>`_
- `PowerStore: Unable to connect to a node using Serial Over LAN (SOL) with IPMI <https://www.dell.com/support/kbdoc/en-us/000131664/powerstore-unable-to-connect-to-a-node-using-serial-over-lan-sol-with-ipmi>`_
