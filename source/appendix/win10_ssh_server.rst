.. _win10_ssh_server:

===================
Windows 10 SSH服务
===================

我在工作中很少使用Windows，主要因为我的运维工作基于Linux服务器，也习惯使用macOS作为桌面。不过，近期想完全切换到Linux桌面 :ref:`arch_linux` ，以便能够更好锻炼技术。

不过，工作中无法避免的是少数应用软件没有WEB方式或者强制只提供Windows/macOS版本，比如，工作中必用的IM工具以及公司特定的安全软件。

变通的方法是 :ref:`create_vm` 运行Windows，然后在Windows中通过 :ref:`seamless_rdp` 方式 **远程** 运行Windows应用 (实际上是本地笔记本的虚拟机)，虽然有些浪费系统资源，但是强烈的技术好奇心使得这种看似多此一举的的运行方式也有一席用武之地。

Windows虚拟机中启动SSH Server是为了能够作为跳板机，从Linux主机先登陆Windows虚拟机，再访问运维服务器。



参考
=========


