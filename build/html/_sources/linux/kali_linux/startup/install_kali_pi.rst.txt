.. _install_kali_pi:

======================
树莓派安装Kali Linux
======================

Kali Linux支持多种平台运行，对于 :ref:`arm` 设备，通过 `Kali-ARM-Build-Scripts <https://gitlab.com/kalilinux/build-scripts/kali-arm>`_ 工具，提供了不同 `Kali Linux ARM Images <https://www.offensive-security.com/kali-linux-arm-images/>`_ ，并且针对不同的树莓派设备提供了32位和64位镜像。

.. note::

   我准备在 :ref:`pi_400` 和 :ref:`pi_zero` 上分别实践64位和32位的ARM版本Kali Linux，学习Linux安全技术以及尝试ARM平台开发。

安装
=======

ARM版本的Kali Linux安装和其他ARM Linux操作系统安装方法类似，都是采用 ``dd`` 命令将镜像复制到SD卡，然后通过SD卡启动设备::

   xzcat kali-linux-2021.1-rpi4-nexmon-64.img.xz | dd of=/dev/sdb bs=4M

启动设备之后，首次登陆用户名和密码都是 ``kali`` 需要立即修改账号密码。见 `Kali's Default Credentials <https://www.kali.org/docs/introduction/default-credentials/>`_

启动和运行
===========

首次启动Kali Linux，系统会自动扩展文件系统到整个SD卡，默认启动到图形登陆界面。

和 :ref:`pi_400_4k_display` 相似，默认时显示器周边有黑边，这和 ``Underscan/overscan`` 相关，不过Kali Linux Raspberry Pi没有提供 ``raspi-config`` ，所以我参考 :ref:`pi_400_4k_display` 通过 ``raspi-config`` 工具生成的 ``/boot/config.txt`` 修改如下::

   disable_overscan=1   

然后重启一次系统生效

初始设置
=========

Kali Linux 2021.1 发行版默认优化已经非常完善，无论Xfce 4.16的界面风格和终端模拟器QTerminal结合zsh，已经让我非常顺手了。

- 修订一下默认的时区::

   unlink /etc/localtime
   ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

这样默认本地时间就能够正确显示。

- 设置本地编码 ``locale`` ::

   echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
   sudo locale-gen

.. note::

   如果不正确设置 ``locale`` ，则很多命令执行时候会出现设置locale报错，类似::

      perl: warning: Setting locale failed.
      perl: warning: Please check that your locale settings:
              LANGUAGE = (unset),
              LC_ALL = (unset),
              LC_CTYPE = "UTF-8",
              LC_TERMINAL = "iTerm2",
              LANG = (unset)
          are supported and installed on your system.
      perl: warning: Falling back to the standard locale ("C").
      ...

   不过，在执行 ``virsh list`` 依然提示信息::

      setlocale: No such file or directory

   通过执行 ``LANG=en_US.UTF-8 locale`` 查看可以看到::

      locale: Cannot set LC_CTYPE to default locale: No such file or directory
      locale: Cannot set LC_ALL to default locale: No such file or directory
      LANG=en_US.UTF-8
      LANGUAGE=
      LC_CTYPE=UTF-8
      LC_NUMERIC="en_US.UTF-8"
      LC_TIME="en_US.UTF-8"
      LC_COLLATE="en_US.UTF-8"
      LC_MONETARY="en_US.UTF-8"
      LC_MESSAGES="en_US.UTF-8"
      LC_PAPER="en_US.UTF-8"
      LC_NAME="en_US.UTF-8"
      LC_ADDRESS="en_US.UTF-8"
      LC_TELEPHONE="en_US.UTF-8"
      LC_MEASUREMENT="en_US.UTF-8"
      LC_IDENTIFICATION="en_US.UTF-8"
      LC_ALL=

   可以看到 ``LC_CTYPE`` 和 ``LC_ALL`` 没有调整成 ``en_US.UTF-8`` ，你可以通过设置环境变量 ``LC_CTYPE`` 和 ``LC_ALL`` 来解决这个问题::

      export LC_CTYPE=en_US.UTF-8
      export LC_ALL=en_US.UTF-8

   则再执行 ``virsh list`` 就不再报错。

   或者重启主机也可以解决。

   以上参考 `"setlocale: No such file or directory" on clean Debian installation #144 <https://github.com/mobile-shell/mosh/issues/144>`_

- :ref:`kali_network`

- 为了方便开发学习，设置 :ref:`virtualenv` 完成Python 3开发环境::

   sudo apt install python3-venv
   cd ~
   python3 -m venv venv3
   source venv3/bin/active

Kali Linux 2021.1 Release
==========================

我所使用的Kali Linux 2021.1版本是2021年2月24日发布，具有很多有趣的特性:

- 默认采用 Xfce 4.16 版本: Xfce 4.16当前最新的 :ref:`xfce` 稳定版本(2020年12月22日发布)，Kali Linux在此基础上作了优化(基于Xfce调优了GTK3 theme)，形成了非常美观的现代化界面

.. figure:: ../../../_static/linux/kali_linux/startup/xfce-414-new.png
   :scale: 40

- 提供了可选的 KDE 5.20 (Plasma) 作为Kali官方支持的桌面，安装过程也可以选择GNOME。此外，系统安装完成后，还可以选择安装Enlightenment, i3, LXDE 和 MATE

- 提供了不同终端工具

- 提供了 ``command-not-found`` 工具来帮助使用(当输入命令错误时会提供相近命令提示)，激活方法如下::

   # enable command-not-found if installed
   if [ -f /etc/zsh_command_not_found  ]; then
       . /etc/zsh_command_not_found
   fi

参考
=====

- `Kali on Raspberry Pi2 <https://www.kali.org/docs/arm/kali-linux-raspberry-pi-2/>`_
- `Kali Linux 2021.1 Release (Command-Not-Found) <https://www.kali.org/blog/kali-linux-2021-1-release/>`_
