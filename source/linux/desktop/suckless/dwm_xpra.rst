.. _dwm_xpra:

=================
结合dwm和xrpa
=================

在 :ref:`edge_cloud` 的 ``x-adm`` :ref:`pi_400` 主机上安装了 :ref:`raspberry_pi_os` 系统，图形管理系统采用 :ref:`dwm` 。这个精简的图形系统，配合树莓派有限的硬件资源，能够更好帮助我完成日常开发运维工作:

- 真正的大规模计算运行都在远程服务器
- 本地只运行精简图形系统

图形桌面
================

- 在xpra中启动 :ref:`dwm` ::

   xpra start-desktop --start-child=dwm --exit-with-children :11

注意这里参数:

  - ``--start-child`` 参数要配合 ``--exit-with-children`` 一起
  - ``start-desktop`` 启动桌面
  - ``:11`` 这里选择较大的数值，否则会提示和现有正在运行的xserver的桌面冲突，例如我使用 ``:7`` 就提示错误 ``WARNING: low display number: 7``

- 在客户端配置好 :ref:`ssh_proxycommand` ，即在 ``~/.ssh/config`` 中添加配置::

   Host x-adm
       HostName 192.168.7.1
       ProxyCommand ssh -W %h:%p zcloud-ip

以及在 ``/etc/hosts`` 添加 ``zcloud-ip`` 的主机解析(中间ssh服务器，具体IP按实际情况)::

   xx.xx.xx.xx zcloud-ip

- 客户端使用以下命令访问后端 ``x-adm`` 上的xpra服务::

   xpra --ssh=ssh attach ssh://x-adm/11

此时，会显示远程服务器上的完整 :ref:`dwm` 桌面:

.. note::

   这里遇到一个问题，似乎不能相应组合键，不确定是不是我使用 MacBook 笔记本组合键不一致。需要再研究一下。


