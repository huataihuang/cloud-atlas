.. _win10_multi_rdp_sessions:

==========================
Windows 10远程桌面多会话
==========================

Windows 10远程桌面(Remote Desktop, RDP)和Sever版本的Terminal Service不同的是：Windows 10不允许多个帐号同时并发使用远程桌面。这是微软的操作系统版本区分策略，实际上Windows 10也能够开启多个RDP会话，就好像服务器版本一样。

.. note::

   我在这里探索Windows 10远程桌面多会话功能，实际上是因为在研究 :ref:`seamless_rdp` 发现Windows 10不能实现类似Windows Server一样的seamless RDP。经过一些探索，我发现主要原因应该是Windows 10 Pro不支持Terminal Server的RemoteApp方式运行程序。Seamless RDP可能是Terminal Server的RemoteApp形式的包装，所以只能在Windows Server上实现。

Terminal Server
===============

seamlessrdp 需要服务器端使用Terminal Server，也就是能够在服务器端 `Publishing RemoteApps in Windows Server 2012 <https://social.technet.microsoft.com/wiki/contents/articles/10817.publishing-remoteapps-in-windows-server-2012.aspx>`_ 或者类似在 Windows Sever 2008上参考 `TS RemoteApp Step-by-Step Guide <https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc730673(v=ws.10)?redirectedfrom=MSDN>`_ ，而Windows 10 Pro恰恰没有提供Terminal Server功能。勤劳朴实的Haker提供了以下两种方案实现 `Multiple RDP (Remote Desktop) sessions in Windows 10 <https://www.mysysadmintips.com/windows/clients/545-multiple-rdp-remote-desktop-sessions-in-windows-10>`_ ：

- 修改 termsrv.dll
- 部署开源的RDP Wrapper中间层

编辑 ``termserv.dll`` 可以使用免费的 `Tiny Hexer <http://texteditors.org/cgi-bin/wiki.pl?Tiny_Hexer>`_ 编辑器。

**Windows 10 x64 v1903 - May 2019 Update** 修订 ``C:\Windows\System32\termsrv.dll`` 

将::

   39 81 3C 06 00 00 0F 84 5D 61 01 00

修改成::

   B8 00 01 00 00 89 81 38 06 00 00 90


``C:\Windows\System32\termsrv.dll`` 是系统文件，无法直接编辑或者替换(例如我将文件复制出来修改以后想再复制回去覆盖原先的系统文件)。

- 你需要首先把文件 ``take own`` 成自己(使用administrator权限运行command prompt) ::

   takeown /f C:\Windows\system32\termsrv.dll

- 然后首选自己administrators完全访问和控制该文件::

   icacls C:\Windows\system32\termsrv.dll /grant administrators:F

- 停止远程桌面服务(通过 ``Computer Managerment`` 的Services管理 )

- 现在就可以复制文件进行系统文件替换::

   copy C:\Users\huatai\Desktop\termsrv.dll C:\Windows\system32\termsrv.dll

- 然后再次启动远程桌面服务

现在Windows 10的多个用户帐号可以同时发起RDP远程桌面访问Windows 10系统，如果将Windows 10作为远程桌面服务器，运行多个办公环境，可以极大节约硬件资源。

参考
=====

- `How to fix corrupted system files in Windows 10 <https://www.thewindowsclub.com/how-to-fix-corrupted-system-files-in-windows-10>`_
- `Multiple RDP (Remote Desktop) sessions in Windows 10 <https://www.mysysadmintips.com/windows/clients/545-multiple-rdp-remote-desktop-sessions-in-windows-10>`_

