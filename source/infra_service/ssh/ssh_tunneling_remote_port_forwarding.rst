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

例如，我使用 :ref:`sphinx_doc` 撰写 `readthedocs平台上的云图 <https://cloud-atlas.readthedocs.io/zh_CN/lastest/index.html>`_ ，但是每次都要推送到 github 上才能刷新到readthedocs平台，显然比较繁琐。假如互联网上有人想要阅读我最新撰写的文档，那最快捷的方式就是使用互联网上的一个VPS做远程服务端口转发。

- 在我撰写的 ``Cloud Atlas`` 的html目录下启动Python3 的 ``http.server`` 模块服务::

   cd cloud-atlas/build/html
   python3 -m http.server 20080

此时我的笔记本上启动了一个简单的http服务，监听端口是 ``20080``

- 现在登陆到远程VPS上，启用远程端口映射::

   ssh -R 20080:<myserver_ip>:20080 user@<myserver_ip>

举例::

   #ssh -R 20080:192.168.10.101:20080 huatai@cloud-atlas.huatai.me
   ssh -R 20080:localhost:20080 huatai@cloud-atlas.huatai.me

异常排查
----------

我遇到一个奇怪的问题，执行了上述命令之后，在远程服务器上检查::

   netstat -an | grep 20080

却发现远程服务器端口是绑定在 ``127.0.0.1`` 上，而不是所有网络借口::

   tcp        0      0 127.0.0.1:20080         0.0.0.0:*               LISTEN
   tcp6       0      0 ::1:20080               :::*                    LISTEN

而且即使我添加了远端服务器的IP地址指定 ``[REMOTE:]REMOTE_PORT`` 也是如此

仔细看了一下服务器端的 ``/etc/ssh/sshd_config`` 配置，以下配置似乎可疑::

   #GatewayPorts no

也就是说，默认 ``sshd`` 是设置为 ``GatewayPorts no`` 。

在 ``man ssh`` 中有说明:

By default, TCP listening sockets on the server will be bound to the loopback interface only. This may be overridden by specifying a bind_address. An empty bind_address, or the address ‘*’, indicates that the remote socket should listen on all interfaces. Specifying a remote bind_address will only succeed if the server's GatewayPorts option is enabled (see sshd_config(5)).

即，如果要绑定所有接口，则使用 ``*`` 或者空白的远程服务器地址；但是要使得远程服务器的指定绑定地址，只有激活 ``GatewayPorts yes`` 才行。

所以，需要在服务器上配置::

   GatewayPorts yes

然后再次执行::

   ssh -R 20080:localhost:20080 huatai@cloud-atlas.huatai.me

此时在服务器上检查::

   netstat -an | grep 20080

就可以看到::

   tcp        0      0 0.0.0.0:20080           0.0.0.0:*               LISTEN
   tcp6       0      0 :::20080                :::*                    LISTEN

此时访问 http://cloud-atlas.huatai.me:20080/ 就会看到自己本地笔记本上的 python http.server 显示有访问，同时浏览器中可以看到自己的WEB页面，这表明已经将本地主机上的服务输出到因特网上，对外提供服务。

参考
======

- `How to Set up SSH Tunneling (Port Forwarding) <https://linuxize.com/post/how-to-setup-ssh-tunneling/>`_
- `SSH: Troubleshooting "Remote port forwarding failed for listen port" errors <https://superuser.com/questions/1194105/ssh-troubleshooting-remote-port-forwarding-failed-for-listen-port-errors>`_
