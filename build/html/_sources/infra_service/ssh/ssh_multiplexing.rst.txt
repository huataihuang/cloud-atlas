.. _ssh_multiplexing:

=============================
ssh多路传输multiplexing加速
=============================

Multiplexing的优点
=======================

SSH multiplexing 的一个优点是克服了创建一个新的TCP连接的消耗。对于一个主机可以接受的连接数量是有限的，并且对于一些主机限制更为明显，这和主机的负载有关，并且开启一个新的连接会有明显的延迟。当使用multiplexing的时候，重用一个已经开启的连接可以明显加速。 

multiplexing和独立会话的区别是，在服务器和客户端，都只看到一个进程（即使多次连接会话）。并且，在服务器和客户机上，可以看到只打开了一个TCP连接；只不过，在客户端，后建立的会话都是通过 ``stream`` 的本地套接字来访问的。OpenSSH使用现有的TCP连接来实现多个SSH会话，这种方式降低了新建TCP连接的负载。

参考
=========

- `OpenSSH/Cookbook/Multiplexing <https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Multiplexing>`_
- `Mostly unknown OpenSSH tricks <https://blog.flameeyes.eu/2011/01/mostly-unknown-openssh-tricks>`_
- `Speeding up SSH Session Creation <https://developer.rackspace.com/blog/speeding-up-ssh-session-creation/>`_
- `OpenSSH Multiplexer To Speed Up OpenSSH Connections <http://www.cyberciti.biz/faq/linux-unix-osx-bsd-ssh-multiplexing-to-speed-up-ssh-connections/>`_
- `Close ssh session that has ControlPersist and is kept alive in the background <http://unix.stackexchange.com/questions/49912/close-ssh-session-that-has-controlpersist-and-is-kept-alive-in-the-background>`_
