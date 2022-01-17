.. _ssh_multiplexing:

=============================
ssh多路传输multiplexing加速
=============================

Multiplexing的优点
=======================

SSH multiplexing 的一个优点是克服了创建一个新的TCP连接的消耗。对于一个主机可以接受的连接数量是有限的，并且对于一些主机限制更为明显，这和主机的负载有关，并且开启一个新的连接会有明显的延迟。当使用multiplexing的时候，重用一个已经开启的连接可以明显加速。 

multiplexing和独立会话的区别是，在服务器和客户端，都只看到一个进程（即使多次连接会话）。并且，在服务器和客户机上，可以看到只打开了一个TCP连接；只不过，在客户端，后建立的会话都是通过 ``stream`` 的本地套接字来访问的。OpenSSH使用现有的TCP连接来实现多个SSH会话，这种方式降低了新建TCP连接的负载。

``Multiplexing`` 的创建过程：

-  设置 ``ControlMaster`` 开启一个本地Unix domain socket
-  其余的所有的ssh命令连接都通过Unix domain socket连接到 ``ControlMaster``

``ControlMaster`` 提供了以下优点：

-  使用已经存在的unix socket
-  没有新增的TCP/IP连接
-  不再需要密钥交换
-  不再需要认证等

以下是在一个Mac OS X 客户端，登陆过Linux服务器之后，关闭终端，然后又发起4次ssh登陆（没有退出）情况下的检查： 

-  Mac OS X客户端检查进程::

    ps aux | grep 192.168.1.1 | grep -v grep 

可以看到，系统只建立了一个ssh连接进程(有一个 ``[mux]`` 标记是 ``Multiplexing`` ::

    huatai          59773   0.0  0.0  2490964    600   ??  Ss    3:03PM   0:00.17 ssh: /Users/huatai/.ssh/192.168.1.1-22-root [mux]

- Mac OS X客户端检查连接::

   netstat -an | grep 192.168.1.1

可以看到，除了第一个ssh连接是直接连接服务器的22端口，其他ssh连接都是连接本地的socket::

   tcp4       0      0  192.168.1.2.51210      192.168.1.1.22        ESTABLISHED
   5a240da08f6284a9 stream      0      0                0 5a240da069f57959                0                0 /Users/huatai/.ssh/192.168.1.1-22-root.FqablQb5EvN7v2Yj
   5a240da083696e09 stream      0      0                0 5a240da07cccff31                0                0 /Users/huatai/.ssh/192.168.1.1-22-root.FqablQb5EvN7v2Yj
   5a240da08fe2c701 stream      0      0                0 5a240da05ffa3f91                0                0 /Users/huatai/.ssh/192.168.1.1-22-root.FqablQb5EvN7v2Yj
   5a240da08a80ec79 stream      0      0                0 5a240da069f56441                0                0 /Users/huatai/.ssh/192.168.1.1-22-root.FqablQb5EvN7v2Yj
   5a240da069f57251 stream      0      0 5a240da06f2ca8c9                0                0                0 /Users/huatai/.ssh/192.168.1.1-22-root.FqablQb5EvN7v2Yj

- 在Linux服务器上观察可以看到进程::

   ps aux | grep ssh | grep -v grep

显示只有一个客户端连接::

   root      1052  0.0  0.0  82548  3536 ?        Ss   Jan27   0:05 /usr/sbin/sshd -D
   root     34640  0.0  0.0 140788  4988 ?        Ss   15:03   0:00 sshd: root@pts/0,pts/1,pts/2,pts/3

观察客户端ssh连接也确实只有一个::

   netstat -an | grep 192.168.1.2

输出显示::

   tcp        0     36 192.168.1.1:22         192.168.1.2:51210       ESTABLISHED

从上述观察来看，启用了 ``Multiplexing`` 之后，客户机和服务器只需要建立一个SSH连接，就能够满足客户端大量的并发连接

设置Multiplexing
====================

OpenSSH通过 ``ControlMaster`` ， ``ControlPath`` 和 ``ControlPersist`` 配置来实现multiplexing:

-  ``ControlMaster`` 决定ssh是否监听控制连接并且如何处理
-  ``ControlPath`` 是控制套接字的位置
-  ``ControlPersist`` 是配合 ``ControlMaster`` 设置，如果设置成 ``yes`` 则会在后台始终开启主连接来接受新的连接，只到被明确地杀死或者通过 ``-O`` 参数关闭。

.. note::

   ``ControlPersist`` 选项需要 OpenSSH 5.6以上版本支持，否则会ssh时会提示错误::

      Bad configuration option: ControlPersist

- 在用户目录下配置 ``~/.ssh/config`` 内容如下::

   Host machine1
     HostName machine1.example.org
     ControlPath ~/.ssh/controlmasters/%r@%h:%p
     ControlMaster auto
     ControlPersist 10m

上述配置，就会在 ``~/.ssh/controlmasters/`` 目录下创建控制套接字

-  ``Host machine1`` 也如果配置成 ``Host *`` 则表示匹配所有的主机，则不需要设置 ``HostName``
-  ``ControlPath ~/.ssh/controlmasters/%r@%h:%p`` 设置用于共享连接的控制unix套接字路径。变量 ``%r`` ， ``%h`` 和 ``%p`` 表示远程ssh连接的用户名，主机名和端口。
-  ``ControlMaster`` 设置成 ``auto`` 则会无条件接受新的连接，如果这个参数设置成 ``10`` 就只能接受10个多路会话。
-  ``ControlPersist 10m`` 设置主连接保持在后台打开的时间是10分钟。如果没有客户端连接，这个后台master连接将自动终止。

.. note::

   从OpenSSH 6.7开始 ``%r@%h:%p`` 可以合并成 ``%C`` ，这个参数会自动生成 ``%l%h%p%r`` 的哈希，优点是可以唯一标识连接

也可以配置成通用配置(对所有服务器生效)::

   Host *
     ServerAliveInterval 60
     ControlMaster auto
     ControlPath ~/.ssh/%h-%p-%r
     ControlPersist yes
     StrictHostKeyChecking no
     Compression yes

.. note::

    这里还添加了压缩以及不检查服务器SSH key(有安全风险，但是对于有安全控制对测试环境，不断重建服务器并使用相同IP，可能需要这个参数)

管理连接套接字
------------------

- 选项 ``-O`` 用来管理连接::
 
   ssh -O check machine1
   ssh -O stop machine1

.. note::

   这个 ``-O stop`` 会清除掉旧的控制套接字，原先的已经连接的会话不受影响。新的连接将建立新的TCP连接。

手工建立multiplex连接
============================

使用参数 ``-M`` 和 ``-S`` 对应的就是 ``ControlMaster`` 和 ``ControlPath`` ，所以可以使用如下命令创建多路传输:

   ssh -M -S /home/fred/.ssh/controlmasters/fred@server.example.org:22 server.example.org

后续的ssh可以使用 ``-S`` 参数复用前面创建的控制套接字::

   ssh -S /home/fred/.ssh/controlmasters/fred@server.example.org:22 server.example.org

结束multiplex连接
======================

::

   ssh -O stop server1
   ssh -O stop -S ~/.ssh/controlmasters/fred@server1.example.org:22 server1.example.org

参考
=========

- `OpenSSH/Cookbook/Multiplexing <https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Multiplexing>`_
- `Mostly unknown OpenSSH tricks <https://blog.flameeyes.eu/2011/01/mostly-unknown-openssh-tricks>`_
- `Speeding up SSH Session Creation <https://developer.rackspace.com/blog/speeding-up-ssh-session-creation/>`_
- `OpenSSH Multiplexer To Speed Up OpenSSH Connections <http://www.cyberciti.biz/faq/linux-unix-osx-bsd-ssh-multiplexing-to-speed-up-ssh-connections/>`_
- `Close ssh session that has ControlPersist and is kept alive in the background <http://unix.stackexchange.com/questions/49912/close-ssh-session-that-has-controlpersist-and-is-kept-alive-in-the-background>`_
