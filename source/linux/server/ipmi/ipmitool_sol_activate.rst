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

**解决方法:** :ref:`ubuntu_serial_console`

ssh会话和推出IPMI SOL
==========================

当使用 ``sol activate`` 连接到控制台，要断开IPMI SOL时，我们会使用 ``~.`` 。但是有一个问题，如果是在 ``ssh`` 连接中使用 ``~.`` 退出IPMNI SOL连接，会导致SSH会话断开。

解决的方法是使用 ``~~.`` (也就是连输两个 ``~`` )

原因是 ``~`` 也是 ssh 的关闭会话请求。当使用两个 ``~`` 时，则ssh会进行转义(默认转义符号是 ``~`` )，这样就会确保 ``~`` 不被ssh接收，而将第二个 ``~`` (也就是一个 ``~`` )转发到远程系统，也就是被IPMI控制台接收到。

参考
=======

- `ipmitool: lanplus: hanging on getting cipher suites <https://www.suse.com/support/kb/doc/?id=000020250>`_
- `PowerStore: Unable to connect to a node using Serial Over LAN (SOL) with IPMI <https://www.dell.com/support/kbdoc/en-us/000131664/powerstore-unable-to-connect-to-a-node-using-serial-over-lan-sol-with-ipmi>`_
- `How to exit IPMI SOL session without exiting the ssh session? <https://stackoverflow.com/questions/68847152/how-to-exit-ipmi-sol-session-without-exiting-the-ssh-session>`_
