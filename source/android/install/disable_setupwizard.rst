.. _disable_setupwizard:

=============================
禁用Android初始化设置Wizard
=============================

在 :ref:`android_10_pixel_xl` 后，由于原生Android默认安装了GMS，开机启动第一次初始化会强制要求连接到Google服务进行账号注册。这带来了一个死循环：

- 在墙内系统无法直接访问Google
- 没有完成初始化无法跳过进入系统，也就无法使用 :ref:`openconnect_vpn` 来访问Google

总之，没有Google无法激活，原先我记得连接局域网注册失败，再尝试一次通过移动网络注册失败，Andorid的Setup Wizard是会提供一个选项允许暂时跳过设置。但是，最近一次刷新Factory Image，却发现这个跳过选项没有了。这就导致无法进入Android系统使用手机。

解决思路：

- 参考 :ref:`root_pixel` ，使用TWRP的IMG文件进入系统，mount选项挂载上system
- 修改 ``/system/build.prop`` 参数，添加一行::

   ro.setupwizard.mode=DISABLED

然后再次启动系统就会跳过Wizard，这样就可以再安装openconnect来连接Google，就可以重新注册了。

步骤
======

- 重启手机操作系统，重启同时按住 ``音量减小键`` ，这样重启后进入fastboot模式

- 下载 `twrp-3.3.1-3-marlin.img <https://dl.twrp.me/marlin/twrp-3.3.1-3-marlin.img.html>`_ 在电脑上执行以下命令以便从TWRP img启动::

   fastboot boot twrp-3.3.1-3-marlin.img

- 启动TWRP之后，在界面上选择 ``mount`` 挂载system，不过只能选择readonly，挂载后在电脑上执行::

   adb shell

进入系统检查::

   df -h

可以看到::

   /dev/block/sda33 1.9G  1.9G   47M  98% /system

重试重新挂载成读写模式::

   mount -o remount,rw /system

但是报错::

   linker: Warning: couldn't read "/system/etc/ld.config.txt" for "/sbin/toybox" (using default configuration instead): error reading file "/system/etc/ld.config.txt": Too many symbolic links encountered
   WARNING: linker: Warning: couldn't read "/system/etc/ld.config.txt" for "/sbin/toybox" (using default configuration instead): error reading file "/system/etc/ld.config.txt": Too many symbolic links encountered
   '/dev/block/bootdevice/by-name/system_a' is read-only

这里比较奇怪，参考 `How can I remount my Android/system as read-write in a bash script using adb?
Ask Question <https://stackoverflow.com/questions/28009716/how-can-i-remount-my-android-system-as-read-write-in-a-bash-script-using-adb>`_ 通常需要使用root身份来执行adb mount，不过我检查了::

   adb root

显示输出::

   adbd is already running as root

这个问题有待进一步探索，目前主要困难在于 ``-o remount,rw`` 无法挂载Pixel的系统目录。

`Skipping Setup Wizard on first boot of LineageOS or any Android ROM <http://blogs.unbolt.net/index.php/brinley/2017/04/22/skipping-setup-wizard-on-first-boot>`_ 介绍了几种跳过Setup Wizard



剔除GMS
==========

实际上有一个非常简单的禁止Google SetupWizard的方法，就是使用第三方编译的Android系统，例如LineageOS。第三方编译的Android系统不包含Andrid Google Mobile Services(GMS)，所以就不会启动默认强制连接注册Google服务。

ZEBRA开发网站提供了一系列 `The Android Setup Wizard and How to Bypass It <https://developer.zebra.com/blog/android-setup-wizard-and-how-bypass-it>`_ ，通过企业管理Android可以绕过Setup Wizard。

如果实在不能跳过Andorid SetupWizard，可以尝试使用LineageOS来替代:

* LineageOS 16.0 = Android 9.0.0 (Pie)
* LineageOS 17.0/17.1 = Android 10  这个版本非LineageOS官方发布版

参考
========

- `android 7.12修改build.prop跳过开机验证 <https://www.jianshu.com/p/ffd18cf54b02>`_
