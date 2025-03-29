.. _win10_ssh:

====================
Windows 10 SSH服务
====================

Windows 10 1809 和 Windows 2019已经内建了OpenSSH Client和OpenSSH Server。

.. note::

   此外 `PowerShell Github仓库提供了OpenSSH <https://github.com/PowerShell/OpenSSH-Portable>`_

安装
=====

Windows 10 1809 提供了OpenSSH client和server的安装功能:

- 点击启动按钮，然后选择 ``Settings => Apps`` ，在选择 ``Apps & features => Optional Feature``

.. figure:: ../../_static/windows/service/win10_ssh_1.png
   :scale: 60

- 默认已经安装了OpenSSH client，只需要安装OpenSSH Server，所以点击 ``Add a feature``

.. figure:: ../../_static/windows/service/win10_ssh_2.png
   :scale: 60

- 点击安装OpenSSH Server
   
.. figure:: ../../_static/windows/service/win10_ssh_3.png
   :scale: 60

启用
=====

- 在启动按钮上右击鼠标，选择 ``Computer Management`` ，然后在主机管理程序中选择 ``Services and Applications => Services``

- 在服务列表中选择 ``OpenSSH SSH Server`` ，然后点击启动按钮启动服务，就可以通过ssh登陆到Windows 10系统中

- 在 ``OpenSSH SSH Server`` 项目上右击鼠标，选择 ``Properties`` ，在属性配置中，将 ``Startup type`` 修改成 ``Automatic`` ，这样下次Windows 10启动时自动启动 OpenSSH Server

参考
======

- `Installation of OpenSSH For Windows Server 2019 and Windows 10 <https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse>`_
