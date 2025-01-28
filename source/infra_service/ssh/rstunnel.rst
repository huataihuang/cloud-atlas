.. _rstunnel:

==================
RSTunnel
==================

`GitHub: JayGoldberg/RSTunnel <https://github.com/JayGoldberg/RSTunnel>`_ 是一个可靠的SSH Tunnel的持续维护，但是它不需要 :ref:`autossh` 就可以工作。这个 ``RSTunnel`` (可靠 SSH Tunnel)是一组 **纯shell脚本** (兼容 ``/bin/sh`` )用于维护从客户端到服务器的安全隧道。

:ref:`autossh` 的麻烦之处是它是 :ref:`clang` 程序，需要为不同的架构平台编译，而获取交叉编译工具链并非易事，所以最好依赖大多数操作系统内置的二进制文件。 ``RSTunnel`` 目标是只使用 :ref:`shell` ，而且兼容最简单的 ``ash`` ，以及能够兼容像dropbear SSH这种不常用的客户端。

- 简单查看一下 ``rstunnel`` 脚本，就可以看到关键的一句检查SSH Tunnel是否正常工作的语句:

.. literalinclude:: rstunnel/nc
   :caption: 通过 ``nc`` 工具检查SSH Tunnel是否工作
   :emphasize-lines: 2,4

脚本写得很精简，阅读可以理解原理以及辅助逻辑

.. _ctunnel:

CTunnel
=========

.. note::

   我比较习惯使用SSH config来控制SSH，所以我fork了RSTunnel改写了一个 `CTunnel(持久化Tunnel) <https://github.com/huataihuang/CTunnel>`_ (还比较粗糙，待改进)

- 随脚本提供了一个 ``install`` 工具，用于通过交互方式完成安装，实际上就是生成一个 ``rstunnel.conf``

- 运行依赖 ``nc`` 命令，是通过 ``netcat`` 工具包提供，所以需要确保安装:

.. literalinclude:: rstunnel/install_netcat
   :caption: 安装 ``netcat`` 来获得 ``nc``

`nc` 返回124状态码
--------------------

我在主机上配置了每分钟执行一次 ``ctunnel`` ，发现没有正常检测出SSH tunnel的异常: 从外部访问NGINX显示 ``502 Bad Gateway`` ，说明SSH tunnel异常了。

登陆服务器检查，发现ssh进程存在(但应该是不工作了):

.. literalinclude:: rstunnel/ssh_process
   :caption: 显示ssh进程依然存在

而是，确实是可以正常 ``ssh`` 进入服务器(速度很快)，这说明SSH连接是正常的。

但是，根据我的配置，SSH端口转发却无法工作了:

- 从远端NGINX服务器上反向访问代理端口 ``127.0.0.1:24180`` 端口，这里使用 ``telnet`` 模拟访问，显示立即被断开:

.. literalinclude:: rstunnel/telnet
   :caption: telnet测试反向代理端口
   :emphasize-lines: 3

手工执行了一次 ``timeout 3 nc localhost 3128`` ，然后检查 ``echo $?`` 发现返回码是 ``124``

我搞错了，原来通过 ``timeout 3`` 来执行，按照 ``man timeout`` 解释，如果命令超时，并且 ``--preserve-status`` 没有设置，就会返回退出码 ``124`` 。由于 ``nc localhost 3128`` 实际上成功以后是不结束的，通过 ``timeout 3`` 来结束，那么正常情况下拿到的就是 ``124`` 。

实际上脚本是通过如下检测:

.. literalinclude:: rstunnel/check_cmd
   :caption: nc检测命令

我检查发现这种只检查正向端口转发并不能反映反向端口转发的状态。例如，这里检查 ssh 登陆服务器是正常的，正向端口转发 3128 也是正常的，但是反向端口转发就是失败的。

所以脚本要修订为先远程登陆到服务器执行反向端口转发检查:

.. literalinclude:: rstunnel/remote_check_cmd
   :caption: ssh到远程服务器上反向nc检测命令

此时，如果远程服务器反向端口转发异常，会返回:

.. literalinclude:: rstunnel/remote_check_cmd_output
   :caption: ssh到远程服务器上反向nc检测命令输出

修订了 ``ctunnel`` ，在上述失败情况下杀掉ssh进程重连。

不过，我发现一个问题，ssh登陆到远程服务器上检查，如果网络联通，会有两个返回值，一个失败一个成功:

.. literalinclude:: rstunnel/remote_check_cmd_output_fail_success
   :caption: ssh到远程服务器上反向nc检测命令输出有两个返回，什么意思？

为什么ssh反向 ``RemoteForward`` 端口明明是打开的，为何会有两条记录，一个失败一个成功？

我验证发现，似乎这种SSH端口转发情况下，都会出现一条失败( ``(tcp) failed: Connection refused`` )，然后接下来就是成功记录( ``port [tcp/*] succeeded!`` )，不过不影响最后的检查结果( ``$?=0`` )

参考
=======

- `GitHub: JayGoldberg/RSTunnel <https://github.com/JayGoldberg/RSTunnel>`_
