.. _lineageos_20_pixel_4:

==================================
Pixel 4上安装LineageOS 20
==================================

准备工作
========

主机上需要安装 :ref:`adb` 并设置好 ``adb`` 和 ``fastboot`` 并完成设置:

- :ref:`macos` 通过 :ref:`homebrew` 可以完成安装:

.. literalinclude:: ../startup/adb/macos_install_adb
   :caption: 在 :ref:`macos` 上使用 :ref:`homebrew` 安装 ``adb``

- 在设备的系统设置中激活 ``USB debugging`` ，这个激活位于 ``Developer options`` : 选择菜单 ``Settings > About phone`` ，然后在 ``Build number`` 菜单上 ``连续点击7次``

- 选择菜单 ``Settings > Developer options > USB debugging`` ，此时手机上会弹出确认是否信任连接主机，选择信任

- 此时将设备通过USB连接电脑，执行命令:

.. literalinclude:: ../startup/adb/devices
   :caption: ``adb devices`` 检查连接设备

就会看到设备:

.. literalinclude:: ../startup/adb/devices_output
   :caption: ``adb devices`` 显示连接的 :ref:`pixel_4` 设备

:ref:`unlock_bootloader`
==========================

.. note::

   解锁是为了能够刷入第三方ROM，但是也带来无法验证Google官方镜像问题，所以需谨慎

- 在连接 :ref:`pixel_4` 设备情况下，在终端输入如下命令重启手机进入 ``bootloader`` 模式

.. literalinclude:: ../startup/unlock_bootloader/reboot_bootloader
   :caption: 重启设备进入 ``bootloader`` 模式

- 此时在电脑终端上输入如下命令验证设备已经进入 ``fastboot`` 模式:

.. literalinclude:: ../startup/unlock_bootloader/fastboot
   :caption: 验证设备是否进入 ``fastboot`` 模式

正常无出错的话可以看到:

.. literalinclude:: ../startup/unlock_bootloader/fastboot_output
   :caption: 验证正确的 ``fastboot`` 模式输出信息

.. note::

   除了使用 ``adb`` 命令将设备进入 ``fastboot`` 模式，另一种方法是在关机状态下同时按住 ``Volume Down`` + ``Power`` (音量降低键和电源开关键)启动设备，就能进入 ``fastboot`` 模式，进而可以在菜单选择 ``Recoery`` 模式

- 执行以下命令解锁 ``bootloader`` :

.. literalinclude:: ../startup/unlock_bootloader/unlock_bootloader
   :caption: 解锁 ``bootloader``

输出信息类似如下:

.. literalinclude:: ../startup/unlock_bootloader/unlock_bootloader_output
   :caption: 解锁 ``bootloader`` 时提示成功的信息

刷入附加分区
===============

LineageOS刷机需要一个附加分区，(在 ``fastboot`` 模式下)通过刷入 ``dtbo.img`` 来实现(在 :ref:`build_lineageos_20_pixel_4` 输出目录下，也可以从 `LineageOS Pixel 4 BUILDS <https://download.lineageos.org/devices/flame/builds>`_ 下载)

.. literalinclude:: lineageos_20_pixel_4/flash_dtbo
   :caption: 刷入 ``dtbo.img``

输出成功信息:

.. literalinclude:: lineageos_20_pixel_4/flash_dtbo_output
   :caption: 刷入 ``dtbo.img`` 成功

刷入recovery镜像
===================

在 ``fastboot`` 模式下刷入 ``boot.img`` (recovery镜像)(在 :ref:`build_lineageos_20_pixel_4` 输出目录下，也可以从 `LineageOS Pixel 4 BUILDS <https://download.lineageos.org/devices/flame/builds>`_ 下载)

.. literalinclude:: lineageos_20_pixel_4/flash_boot
   :caption: 刷入 ``boot.img``

刷入成功则显示类似如下:

.. literalinclude:: lineageos_20_pixel_4/flash_boot_output
   :caption: 刷入 ``boot.img`` 成功

在recovery模式线安装LineageOS
================================

- 在 ``fastboot`` 模式下，通过手机的音量按钮选择启动菜单选择 ``Recovery Mode``

- 此时会进入 LineageOS 的 RECOVERY(也就是前面刷入的 ``boot.img`` )

- 选择菜单 ``Factory Reset`` ，然后选择 ``Format data / factory reset`` 进入格式化过程，这个过程会清除手机内部存储的所有数据以及移除加密，并且格式化缓存分区(如果有的话)

- 通过音量上下键以及电源按钮(确认)返回到主菜单

- 在主菜单中选择 ``Apply Update`` ，然后选择 ``Apply from ADB`` ，此时手机会等待 ``adb`` 命令侧载安装包

- 在手机终端中输入如下命令 ``sideload`` (侧载) LineageOS ``.zip`` 文件

.. literalinclude:: lineageos_20_pixel_4/sideload_lineageos
   :caption: ``sideload`` (侧载) LineageOS ``.zip`` 文件

此时终端输出 ``sideload`` 过程进度(百分比似乎不准)，完成后输出信息类似:

.. literalinclude:: lineageos_20_pixel_4/sideload_lineageos_output
   :caption: ``sideload`` (侧载) LineageOS ``.zip`` 文件的输出信息

注意，此时电脑终端并没有返回提示符(卡在上述输出信息的最后一行)。但是可以看到手机上提示 ``step1`` 和 ``step2`` 已经进行，此时手机屏幕提示: 如果有进一步安装的软件(也就是GApp)，需要重启到Recovery模式，询问你是否重启到Recovery模式?

此时默认选项是 ``No`` 不重启到Recovery模式。

你可以选择默认的 ``No`` 结束安装，此时电脑终端就返回提示符(表示侧载安装结束):

.. literalinclude:: lineageos_20_pixel_4/sideload_lineageos_output_finish
   :caption: ``sideload`` (侧载) LineageOS ``.zip`` 文件的结束输出信息

.. note::

   如果只安装基本的LineageOS，则过程到此结束。

   不过，通常我们需要安装Google App以便能够获得Google Store, Gmail等程序，所以还会进行下一步

安装 Add-Ons
===============

早期的Google App项目 Open GApps已经不再开发，所以现在如果要使用Google Apps需要安装 `MindTheGapps <https://github.com/MindTheGapps>`_ 。不过，这个 ``MindTheGapps`` 需要按照你安装的Android操作系统选择对应安装包，并且安装包比较庞大，包含了 Google Store, Gmail 等 Google 全家桶软件。

安装需要采用 ``recovery`` 模式:

- 注意，即使当前手机位于recovery模式，也需要选择菜单 ``Advanced`` 然后选择 ``Reboot to Recovery``

- 重启后，点击 ``Apply Update`` ，然后选择 ``Apply from ADB`` ，再在电脑终端中执行以下命令侧载Google App Add-Ons:

.. literalinclude:: lineageos_20_pixel_4/sideload_gapps
   :caption: 侧载安装 ``MindTheGapps``

.. note::

   目前我想采用精简模式来运行 :ref:`pixel_4` ，所以近选择安装 :ref:`lineageos_apps`

下一步
========

为了能够更好使用 :ref:`pixel_4` 的 LineageOS，下一步建议使用 :ref:`magisk` 实现手机 ``root`` ，就能够充分发挥手机功能，例如使用 :ref:`termux` 构建一个 :ref:`mobile_pixel_dev`

参考
======

- `Install LineageOS on Google Pixel 4 <https://wiki.lineageos.org/devices/flame/install>`_
- `LineageOS Wiki: Google apps <https://wiki.lineageos.org/gapps>`_
