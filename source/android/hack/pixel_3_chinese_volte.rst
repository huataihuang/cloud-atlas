.. _pixel_3_chinese_volte:

=================================
配置Pixel 3支持中国运营商VoLTE
=================================

- 首先 :ref:`magisk_root_ota` 安装好Magisk

- 在安装VoLTE-Enabler之前，需要先清理系统的一些文件，这里我们使用 ``adb shell`` 来完成这个操作::

   adb shell

在shell中，执行su命令::

   su -

此时手机上会提示是否给 ``shell`` 以超级用户权限，选择同意。这时就会看到shell的提示符由普通用户的 ``$`` 更改为超级用户的提示符 ``#``

- 删除文件 ``/data/vendor/modem_fdr/fdr_check`` ::

   cd /data/vendor/modem_fdr/
   rm fdr_check

- 删除 ``/data/vendor/radio/`` 目录下所有文件（保持这个文件目录空)::

   cd /data/vendor/radio/
   rm -rf *

- 下载 `[GUIDE] Enabling LTE on China Telecom (and others) on Pixel 3 XL (Android 10) <https://forum.xda-developers.com/t/guide-enabling-lte-on-china-telecom-and-others-on-pixel-3-xl-android-10.4098237/>`_ 提供的 ``Pixel_3_LTE-VoLTE_Enabler.zip`` 文件推送到手机中::

   adb push Pixel_3_LTE-VoLTE_Enabler.zip /sdcard/Download/

- 打开 Magisk Manager ，使用Modules菜单中的 ``Install from Storage`` ，然后安装下载的zip文件，安装完成后按照提示重启系统

- 验证是否正常激活VoLTE的方法是在手机通话同时使用移动运营商的LTE网络，如果通话同时还能移动上网，就表明VoLTE已经正常工作。另外一个特点是，通话会比原先2G语言网络清晰很多，特别是很多地方现在2G网络信号极差，使用VoLTE就没有这个通话问题。

参考
======

- `Download SuperSU APK and SuperSU ZIP <https://magisk.me/supersu/>`_ - 需要注意，SuperSU已经出售给中国的一家公司CCMT，这是一个闭源软件，所以存在潜在风险 ( `Magisk vs SuperSU <https://www.xda-developers.com/magisk-vs-supersu/>`_ )
- `[GUIDE] Enabling LTE on China Telecom (and others) on Pixel 3 XL (Android 10) <https://forum.xda-developers.com/t/guide-enabling-lte-on-china-telecom-and-others-on-pixel-3-xl-android-10.4098237/>`_
