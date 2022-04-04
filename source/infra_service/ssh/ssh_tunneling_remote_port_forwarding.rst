.. _ssh_tunneling_remote_port_forwarding:

=================================
SSH Tunneling: 远程服务端口转发
=================================

:ref:`ssh_tunneling` 可以为应用服务(端口)访问提供加密隧道，可以非常方便实现远程访问内网服务器。此外，SSH端口转发还有一个非常强大的远程服务端口转发功能，可以将远程服务器上的端口访问反向映射回本地主机。这个功能在以下场景非常实用:

- 国内运营商(电信、移动、联通)个人家庭宽带大多都不提供互联网公网IP地址，计算机爱好者不能方便地在家中架设对外提供服务的计算机。你可以在公有云上租用一个非常廉价的VPS，然后采用SSH Tunneling的远程服务端口转发，将VPS的80和443端口映射到家中的主机服务端口上，这样就可以向互联网提供服务
- 如果需要临时将内部主机(例如家中的开发测试主机)的调试端口开放给外部用户联调，也可以使用 SSH Tunneling的远程服务端口转发实现

实际上，这个简单的SSH Tunneling远程端口服务转发就是 :ref:`localtunnel` 的底层实现原理，可以用来构建个人服务器，对internet提供服务。

一条简单的SSH命令
===================

使用以下命令，可以从本地主机上发起一个远程端口转发，建立 :ref:`ssh_tunneling` 之后，internet用户就可以通过访问远程服务器上的 ``REMOTE_PORT`` 访问到你本地局域网 ``DESTINATION`` 主机的 ``DESTINATION_PORT`` ::

   ssh -R [REMOTE:]REMOTE_PORT:DESTINATION:DESTINATION_PORT [USER@]SSH_SERVER



参考
======

- `How to Set up SSH Tunneling (Port Forwarding) <https://linuxize.com/post/how-to-setup-ssh-tunneling/>`_
