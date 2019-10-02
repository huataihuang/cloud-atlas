.. _seamless_rdp:

===========================
Seamless RDP使用Windows应用
===========================

安装rdp客户端
================

Linux平台远程RDP客户端是rdesktop或者freerdp。为了方便使用，可以结合Remmina(图形配置客户端)一起使用。

remmina结合rdesktop
------------------------

需要单独通过AUR安装 ``remmina-plugin-rdesktop`` ::

   pacman -S rdesktop remmina
   yay -S remmina-plugin-rdesktop

.. note::

   编译remmina-plugin-rdesktop 时候报错::

      mmina-plugin-to-build/remmina-plugin-rdesktop/src/remmina_plugin.c:23:
      /usr/include/pango-1.0/pango/pango-coverage.h:28:10: fatal error: hb.h: No such file or directory

   这个问题在 `remmina-plugin-rdesktop 1.2.3.0-1 <https://aur.archlinux.org/packages/remmina-plugin-rdesktop/>`_ 临时的解决方法是修改::

      /usr/include/pango-1.0/pango/pango-coverage.h 
      /usr/include/pango-1.0/pango/pango-font.h

   将::

      #include <hb.h>

   修改成::

      #include <harfbuzz/hb.h>
      
Windows系统Remote Desktop
============================

Windows 10操作系统需要开启远程桌面访问，设置方法：

- 鼠标右击启动按钮，选择 ``System`` ，然后点击 ``Remote Setting``

- 在 ``System Properties`` 设置的 ``Remote`` 面板，有一个 ``Remote Desktop`` 设置区域，选择 ``Allow remote connections to this computer`` 。注意：一定要去除 ``Allow connections only from computers running Remote Desktop with Network Level Authentication (recommended)`` ，否则Linux客户端的rdesktop无法访问。

.. figure:: ../../_static/kvm/win10_rdp_setting.png
   :scale: 75%

SeamlessRDP
================

SeamlessRDP是一个RDP服务器扩展，允许将RDP服务器上运行的Windows应用程序推送到本地桌面，类似RAIL/RemoteApp。SeamlessRDP要求Windows Server 2008r2或更高版本。

通过使用Seamless RDP，远程的Windows程序

请访问 `seamlessrdp github仓库 <https://github.com/rdesktop/seamlessrdp>`_ 获取源代码编译(需要交叉平台编译)，不过官方网站没有提供Windoes的二进制执行程序，以下是我的编译过层。

.. note::

   在Linux平台编译运行在Windows的应用程序，需要预先安装cross-compiling environment for Windows，然后通过参数 ``--host`` 告诉 ``./configure`` 设置合适的交叉编译设置。

编译seamlessrdp::

   git clone https://github.com/rdesktop/seamlessrdp.git
   cd seamlessrdp/
   cd ServerExe/
   ./autogen.sh
   ./configure --host=i686-pc-mingw32
   make

报错::

   main.c:27:10: fatal error: windows.h: No such file or directory
      27 | #include <windows.h>

- 安装

首先打包已经编译输出的Windows执行程序::

   zip -j seamlessrdp.zip .libs/seamlessrdpshell.exe .libs/seamlessrdp??.dll .libs/seamlessrdphook??.exe

将上述 ``seamlessrdp.zip`` 文件复制到Windows服务器的 ``C:\SeamlessRDP\`` 目录中并解压缩

- 使用

在Linux客户端执行以下命令，启动远程Windows平台的notepad应用，此时nodepad程序将显示在本地Linux桌面上，就好像是Linux原生的应用程序::

   rdesktop -A 'C:\SeamlessRDP\seamlessrdpshell.exe' -s 'notepad.exe'

参考
=========

- `arch linux社区文档 - Remmina <https://wiki.archlinux.org/index.php/Remmina>`_
- `arch linux社区文档 - Redsktop <https://wiki.archlinux.org/index.php/Rdesktop>`_
- `Guide - Using Seamless RDP for native looking Windows applications <https://forums.macrumors.com/threads/guide-using-seamless-rdp-for-native-looking-windows-applications.1984261/>`_
- `Remmina Setting <http://www.muflone.com/remmina-plugin-rdesktop/english/settings.html>`_
