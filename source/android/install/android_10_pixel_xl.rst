.. _android_10_pixel_xl:

====================================
在Pixel XL(marlin)上安装Android 10
====================================

.. warning::

   Factory Image恢复设备会导致数据抹除，所以建议采用OTA镜像恢复（不需要解锁也不需要擦除数据）

* 将手机切换到fastboot模式::

   adb reboot bootloader

.. note::

   如果命令行切换失败，可以通过组合键完成切换fastboot模式：关机，同时按住 ``音量减小键`` + ``电源键`` 开机，则切换到fastboot模式。

* 手机解锁bootloader::

   fastboot flashing unlock

.. note::

   美版Pixel/Pixel XL通常是运营商锁版，需要到运营商网站申请解锁，自己无法直接操作。

* 下载完的镜像文件，请先校验SHA256::

   shasum -a 256 marlin-qp1a.191005.007.a3-factory-bef66533.zip

* 解压缩下载的镜像::

   unzip marlin-qp1a.191005.007.a3-factory-bef66533.zip

* 执行 ``flash-all`` 脚本，安装  bootloader, baseband firmware(s), 和操作系统::

   cd marlin-qp1a.191005.007.a3
   ./flash-all.sh

.. note::

   刷工厂镜像，手机必须是解锁的，否则会报错 ``FAILED (remote: 'device is locked. Cannot flash images')``

* 完成刷机以后，再次切换到fastboot模式，然后锁住bootloader (这步可忽略，因为我后续要做Root)::

   fastboot flashing lock

.. warning::

   每次切换lock都会抹除一次系统数据

.. note::

   使用原生Android有一个非常麻烦的地方是，首次启动系统需要注册Google服务，这对墙内用户是一个障碍。解决方法请参考 :ref:`disable_setupwizard` ，不过，实际我并没有解决跳过SetupWizard，而是通过 :ref:`create_ap` 结合 :ref:`openconnect_vpn` 翻墙完成注册。

.. note::

   系统初始化遇到一个问题，国内应用下载往往提供一个二维码扫描，但是原生Android系统并没有任何程序提供二维码扫描(没有微信，支付宝，钉钉...)，解决的方法是先安装 :ref:`openconnect_vpn` ，然后翻墙能够访问Google Play应用商店之后，立即更新Camera，则自带了lens扩展功能，支持扫描二维码以及更多的实物识别功能。

* 如果手机系统已经安装过TWRP，则可以直接刷入更新 - 参考 `Install LineageOS on marlin <https://wiki.lineageos.org/devices/marlin/install>`_

下载 `TWRP for angler <https://dl.twrp.me/marlin/>`_ ，然后刷入::

   fastboot flash recovery twrp-3.3.1-3-marlin.img

但是，如果是首次安装TWRP不能采用直接刷入，否则报错::

   Sending 'recovery' (30961 KB)                      OKAY [  0.831s]
   Writing 'recovery'                                 (bootloader) Flashing active slot "_a"
   FAILED (remote: 'partition [recovery] doesn't exist')
   fastboot: error: Command failed

这个报错需要是因为首次安装TWRP不能直接刷入img文件，应该按照 :ref:`root_pixel` 步骤依次完成。请先完成刷入操作系统，然后再按照 :ref:`root_pixel` 做TWRP recovery安装。

参考
======

- `Factory Images for Nexus and Pixel Devices <https://developers.google.com/android/images#marlin>`_
