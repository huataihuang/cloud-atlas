.. _lineageos_19.1_pixel_3:

==============================
Pixel 3上安装LineageOS 19.1
==============================

虽然 :ref:`android_11_pixel_3` 可以在 :ref:`pixel_3` 上完美运行Android 11 和 12，但是依然有以下不足:

- Google官方镜像打包了太多的Google全家桶应用，很多应用对于我来说完全是无用的鸡肋
- Google官方较早停止了早期旧型号手机的升级支持，包括 :ref:`pixel_3`
- Google为了推广自家的Google TV服务，阉割了官方镜像的Chrome Cast功能

第三方ROM镜像采用了Google的 `AOSP(Android Open Source Project) <https://source.android.com/>`_ ， 通过 :ref:`android_build` 实现了精简系统，提供自定义软件包组合，以及进一步控制定制的能力。 `LineageOS <https://lineageos.org>`_ 作为最早的著名第三方ROM CyanogenMod 的继承者，具有精简和轻量级的特点，我在 :ref:`pixel_3` 上采用LineageOS，方便我实现 :ref:`mobile_pixel_dev` 。

准备工作
=============

- 在个人电脑上安装 :ref:`adb` 
- 解锁bootloader

使用 ``fastboot`` 临时启动一个定制recovery镜像
==================================================

- 下载 `Lineage Recovery <https://download.lineageos.org/blueline>`_ ，只需要简单下载最新的recovery文件，例如 ``lineage-19.1-20220517-recovery-blueline.img``
- 将 :ref:`pixel_3` 手机通过USB连接到电脑主机，然后运行 ``adb`` 检查::

   adb devices

可以看到类似输出::

   List of devices attached
   912X1U972    device  

- 终端命令执行::

   adb reboot bootloader

此时手机会启动到 ``Fastboot Mode`` 模式 ，此时执行以下命令检查::

   fastboot devices

会看到类似输出::

   912X1U972    fastboot

- 将recovery文件刷入设备::

   fastboot flash boot lineage-19.1-20220517-recovery-blueline.img

- 继续启动手机，正常进入Android系统后，长按电源键关机

- 在手机关机状态下，同时按下 ``音量降低键 + 电源键`` ，然后在启动菜单中选择 ``Recovery Mode``

在recovery模式下安装LineageOS
================================

- 下载 `LineageOS安装包 <https://download.lineageos.org/blueline>`_ 或者自己 :ref:`android_build`

  - (可选)下载 `Google Apps <https://wiki.lineageos.org/gapps.html>`_ ，这样可以在刷机时同时安装Google应用获得Google Play Store，方便后续安装应用

    - 根据 `opengapps Package Comparison <https://github.com/opengapps/opengapps/wiki/Package-Comparison>`_ 描述，目前只针对 Android 11 提供了 Pico 和 Nano版本
    - 其他Android版本目前尚未提供(因不确定是否每项都能正确工作)，后续根据发布情况，可以选择最小化的 ``pico`` 版本

- 在 Recovery 模式下选择 ``Factory Reset`` ，然后选择 ``Format data/factory reset`` ，此时会删除掉手机中所有数据并清理缓存
- 返回主菜单页面
- 旁路加载LineageOS ``.zip`` 包:

  - 在手机设备上选择 ``Apply Update`` ，然后选择 ``Apply from ADB``
  - 在主机端，使用以下命令sideload镜像包

::

   adb sideload lineage-19.1-20220517-nightly-blueline-signed.zip

- (可选安装Google Apps)返回主菜单页面，选择 ``Advanced`` ，然后选择 ``Reboot to Recovery`` ，当设备重启以后，选择 ``Apply Update`` ，然后选择 ``Apply from ADB`` ，此时，在主机端执行 ::

   adb sideload MindTheGapps-12.1.0-arm64-20220416_174313.zip

.. note::

   ``Add-ons`` 没有使用LineageOS官方密钥前面，所以此时会提示 ``Signature verification failed`` 。这是正常的，在手机端选择继续安装就可以

- 所有安装都完成后，返回主菜单页面，然后选择 ``Reboot system now``

- 重启完成后即进入最新LineageOS系统，可以看到系统安全补丁是最新的2022年5月(Google官方针对Pixel 3只提供到2021年的安全补丁)

参考
======

- `Install LineageOS on blueline <https://wiki.lineageos.org/devices/blueline/install>`_
