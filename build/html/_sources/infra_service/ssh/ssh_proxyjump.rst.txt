.. _ssh_proxyjump:

===========================
SSH ProxyJump多跳访问主机
===========================

使用 :ref:`ssh_proxycommand` 可以很方便实现2跳SSH，不过，在实现3跳或者更多N跳SSH访问并不直观，使用配置也较为繁琐。SSH的 ``ProxyJump`` 指令在 ``ProxyCommand`` 指令之上构建一个自动在远程主机上执行ssh命令，跳到目标主机并且转发所有通过流量的解决方案。

命令行ProxyJump
======================

使用 ``-J`` 参数可以穿透主机跳下一跳主机::

   ssh -J host1 host2

而且可以添加用户名和端口::

   ssh -J user1@host1:port1 user2@host2 -p port2

甚至可以多跳::

   ssh -J user@host1:port1,user2@host2:port2 user3@host3

配置方式多跳ProxyJump
===========================

- 配置 ``~/.ssh/config`` 类似如下可以实现跳越::

   ssh => pixel => zcloud => z-dev

.. literalinclude:: ssh_proxyjump/ssh_config
   :language: bash
   :caption: SSH ProxyJump多跳配置文件 ~/.ssh/config

- 则简单执行::

   ssh z-dev

就可以连跳3次SSH访问到内部服务器

关闭 ``AllowTcpForwarding``
===============================

出于安全原因，需要关闭中间转跳服务器的ProxyJump功能，则在中间服务器的 ``/etc/sshd_config`` 中添加::

   AllowTcpForwarding no

则上述ProxyJump就会被断开(中间SSH服务器拒绝发起到目标服务器的TCP连接，所以不能构建tunnel)，使用 ``ssh -vvv``  检查时客户端显示::

   ...
   Stdio forwarding request failed: Session open refused by peer
   kex_exchange_identification: Connection closed by remote host

但是，除非禁止用户shell访问，否则依然可能被forwarder绕过。

参考
======

- `gentoo linux wiki: SSH jump host <https://wiki.gentoo.org/wiki/SSH_jump_host>`_
- `SSH tunneling error: "channel 1: open failed: administratively prohibited: open failed" <https://unix.stackexchange.com/questions/14160/ssh-tunneling-error-channel-1-open-failed-administratively-prohibited-open>`_
