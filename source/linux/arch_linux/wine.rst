.. _wine:

=========================
wine环境运行Windows程序
=========================

Wine可以通过激活 multilib 软件仓库进行安装，可以安装 wine (稳定) 和 wine-staging (测试) 软件包。

.. note::

   除了Wine社区以外，还有第三方社团提供类似虚拟化功能，比较出名的有: CrossOver 和 PlayOnLinux (甚至还有 PlayOnMac) 。

   例如，PlayOnLinux提供了较好的的图形设置功能。

- 激活multilib仓库，即编辑 ``/etc/pacman.conf`` 激活::

   [multilib]
   Include = /etc/pacman.d/mirrorlist

- 然后更新一次仓库::

   pacman -Syu

- 安装wine-staging::

   pacman -S wine-staging

- 安装wine_gecko(Internet Explorer)和wine-mono(.NET)::

   pacman -S wine_gecko wine-mono

- 运行winecfg对系统进行配制::

   winecfg

目前采用默认配制，实际上就是先更新一下home目录。其他配制工具还有 ``regedit`` (注册表) 和 ``wine control`` (Windows Control Pannel)。

- 启动IE expolre ``wine iexplore`` ，无法访问https服务报错(可以访问http服务)::

   0036:err:winediag:schan_imp_init Failed to load libgnutls, secure connections will not be available.
   0036:err:winediag:SECUR32_initNTLMSP ntlm_auth was not found or is outdated. Make sure that ntlm_auth >= 3.0.25 is in your path. Usually, you can find it in the winbind package of your distribution.
   0036:err:winediag:load_gssapi_krb5 Failed to load libgssapi_krb5, Kerberos SSP support will not be available.
   0009:fixme:ieframe:handle_navigation_error Navigate to error page
   0009:err:ole:CoReleaseMarshalData StdMarshal ReleaseMarshalData failed with error 0x8001011d

对应安装::

   yay -S lib32-libwbclient

.. note::

   安装编译会提示缺少 m4 和  autom4te ::

      sh: autom4te: command not found
      aclocal: error: echo failed with exit status: 127

   则安装 ``m4`` 和 ``autoconf`` 软件包。

Nvidia
===========

对于32位应用程序，需要安装相应的 ``lib32`` nvidia软件包，这个需要激活上述 ``multilib`` 软件仓库，并安装 ``lib32-nvidia-utils`` 或 ``lib32-nvidia-390xx-utils`` 。

.. note::

   wine运行程序终端提示::

      0206:err:winediag:xrandr12_init_modes Broken NVIDIA RandR detected, falling back to RandR 1.0. Please consider using the Nouveau driver instead.

   我安装了 ``lib32-nvidia-utils`` 也是没有解决。

钉钉
=======

实际上，我安装wine的目的就是运行 ``钉钉`` ，因为这是公司工作通讯的基础软件。可惜原先可以通过WEB使用的钉钉，由于公司限制，只能改为采用原生程序使用。 我尝试过 :ref:`anbox`
方式使用钉钉，不过，发现虚拟化转换X86和ARM有明显的延迟，并且Anbox无法输入中文（安装了Google拼音，但是显示为一块黑色区域)。所以，采用Wine来运行Windows程序，尝试能够完全在Linux平台上工作。

参考 `在deepin linux系统中安装钉钉DingTalk的方法 <https://ywnz.com/linuxjc/5372.html>`_ ，关键的要点是在运行钉钉之前，首先设置好采用Windows的原装库程序代替wine的内建版本，这样就能运行起来，而且基本功能都正常。

- 函数库顶替中分别体添加3个函数库:
  - msvcp60
  - riched20
  - riched32

然后运行钉钉就可以正常工作。

钉钉使用要点
--------------

- 输入框无法点击聚焦，这样就无法输入文字。但是发现把输入框最大化，就可以输入文字。虽然不太方便，但是如果输入文字内容不多还可以接受。

- 双方中文显示正常，但是导航和标题等显示是方框，看来这部分UI显示采用了特定字体，需要从Windows系统复制自体。

- 支持复制粘贴，并且支持中文复制粘贴。但是目前还没有解决中文输入。现在还是在记事本上输入好中文复制粘贴到钉钉中发送。不过，已经比在Windows虚拟机中运行，通过rdesktop远程访问好很多了。

字体
----

如果Wine应用程序不能显示良好字体

参考
=======

- `Arch Linux社区文档 - Wine <https://wiki.archlinux.org/index.php/Wine>`_
- `在deepin linux系统中安装钉钉DingTalk的方法 <https://ywnz.com/linuxjc/5372.html>`_
- `在深度deepin 15.11系统中使用playonlinux安装钉钉(dingtalk)的教程 <https://www.linux110.com/jishu/87.html>`_
