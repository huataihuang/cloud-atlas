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

MacBook Pro高分辨率显示
-------------------------

在MacBook Pro Retina高分辨率屏幕下使用Windows系统会发现自体非常小，这种现象不仅在Windows虚拟机的VNC终端如此，远程桌面如果是Retina屏幕下显示也几乎无法看清字体。解决的方法是调整Windows屏幕缩放比例：

- 启动菜单 ``Settings => System => Display => Advanced scaling settings`` ，在这个设置界面中，可以设置 ``Custom scaling`` ，设置范围可以从 ``100% - 500%`` 。对于MacBook Pro Retina屏幕，这个设置值修改成 ``150`` 较为合适。

修改以后，通过Remote Desktop访问的界面，字体也会相应方法，就能够舒适使用了。

如果需要调整鼠标指针样式：

- 启动菜单 ``Settings => Personalization => Themes`` ，在这个风格设置中，有一个 ``Mouse cursor`` 选项可以调整鼠标指针样式。将样式调整成 ``Windows Black (system scheme)`` 这样 ``可能`` 可以解决rdesktop远程桌面无法正常显示鼠标光标的问题。

.. note::

   参考 `How to fix mouse cursor disappearing on Remote Desktop <https://camerondwyer.com/2018/05/09/how-to-fix-mouse-cursor-disappearing-on-on-remote-desktop/>`_ 不过，这个方法我实践没有成功。

.. note::

   ``rdesktop`` 远程桌面显示的鼠标图形几乎无法看清，上述调整鼠标指针式样依然无法解决。

   在 `Arch Linux社区文档 - Supplying missing cursors <https://wiki.archlinux.org/index.php/Cursor_themes#Supplying_missing_cursors>`_ 提供的解决方案：由于rdesktop使用从远程主机获得的光标，则由于协议限制难以看清。需要使用相同(或其他)光标风格来替代。为了能够替换，需要获得图像的 ``hash`` ，这是通过 ``XCURSOR_DISCOVER`` 环境变量激活，然后查看应用程序使用的光标::

      XCURSOR_DISCOVER=1 rdesktop ...

   首次加载光标就会显示详细信息，例如::

      Cursor image name: 24020000002800000528000084810000
      ...
      Cursor image name: 7bf1cc07d310bf080118007e08fc30ff
      ...
      Cursor hash 24020000002800000528000084810000 returns 0x0

   然后将这些hash软链接到目标图像，例如使用 ``Vanilla-DMZ`` 光标风格的 ``left_ptr`` 图像::

      ln -s /usr/share/icons/Vanilla-DMZ/cursors/left_ptr ~/.icons/default/cursors/24020000002800000528000084810000

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
   #./configure --host=i686-pc-mingw32
   ./configure --host=x86_64-w64-mingw32
   make

报错::

   main.c:27:10: fatal error: windows.h: No such file or directory
      27 | #include <windows.h>

上述报错是因为没有安装跨平台编译环境，例如对于fedora 26需要安装mingw32-gcc和mingw64-gcc。对于arch linux，参考 `MinGW package guidelines <https://wiki.archlinux.org/index.php/MinGW_package_guidelines>`_ 则需要通过 :ref:`archlinux_aur` 安装 ``mingw-w64-gcc`` ::

   yay -S mingw-w64-gcc-base
   yay -S mingw-w64-gcc

.. note::

   先安装 ``mingw-w64-gcc-base`` ，然后安装 ``mingw-w64-gcc`` ，但后者会提示和前者冲突，只要在安装后者同时卸载前者就可以了。

   注意，安装好 ``mingw-w64-gcc`` 之后，还要重新 ``./autogen.sh; ./configure --host=x86_64-w64-mingw32; make`` 。

- 安装

首先打包已经编译输出的Windows执行程序::

   zip -j seamlessrdp.zip .libs/seamlessrdpshell.exe .libs/seamlessrdp??.dll .libs/seamlessrdphook??.exe

将上述 ``seamlessrdp.zip`` 文件复制到Windows服务器的 ``C:\SeamlessRDP\`` 目录中并解压缩

- 使用

在Linux客户端执行以下命令，启动远程Windows平台的notepad应用，此时nodepad程序将显示在本地Linux桌面上，就好像是Linux原生的应用程序::

   rdesktop -A 'C:\SeamlessRDP\seamlessrdpshell.exe' -s 'notepad.exe'

.. note::

   我按照上述方法针对64位Windows环境编译的 :download:`seamlessrdp.zip <seamlessrdp.zip>` ，你可以下载使用。

参考
=========

- `arch linux社区文档 - Remmina <https://wiki.archlinux.org/index.php/Remmina>`_
- `arch linux社区文档 - Redsktop <https://wiki.archlinux.org/index.php/Rdesktop>`_
- `Guide - Using Seamless RDP for native looking Windows applications <https://forums.macrumors.com/threads/guide-using-seamless-rdp-for-native-looking-windows-applications.1984261/>`_
- `Remmina Setting <http://www.muflone.com/remmina-plugin-rdesktop/english/settings.html>`_
