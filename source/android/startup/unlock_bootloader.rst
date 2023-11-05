.. _unlock_bootloader:

==================
解锁Bootloader
==================

解锁bootloader就可以通过 :ref:`adb` 命令刷入镜像，非常方便实现定制镜像或者恢复出厂镜像

unlock bootloader
====================

- 使用命令:

.. literalinclude:: unlock_bootloader/reboot_bootloader
   :caption: 重启设备进入 ``fastboot`` 模式

或者结合使用 ``电源键`` 和 ``音量降低键`` 使得手机进入fastboot模式，然后重启一次bootloader即可，见下文。

- 此时在电脑终端上输入如下命令验证设备已经进入 ``fastboot`` 模式:

.. literalinclude:: unlock_bootloader/fastboot
   :caption: 验证设备是否进入 ``fastboot`` 模式

正常无出错的话可以看到:

.. literalinclude:: unlock_bootloader/fastboot_output
   :caption: 验证正确的 ``fastboot`` 模式输出信息

- 执行以下命令解锁 ``bootloader`` :

.. literalinclude:: unlock_bootloader/unlock_bootloader
   :caption: 解锁 ``bootloader``

输出信息类似如下:

.. literalinclude:: unlock_bootloader/unlock_bootloader_output
   :caption: 解锁 ``bootloader`` 时提示成功的信息

输出信息类似如下:

重新lock bootloader
====================

无锁的bootloader是一个高风险状态，如果没有必要，可以重新lock住bootloader

Pixel 3 bootloader mode
------------------------

- 对于 :ref:`pixel_3` ，首先关机，然后安装 ``电源键`` 和 ``音量降低键`` 开机

- 此时进入 ``Fastboot Mode`` 

- 然后通过 ``音量键`` 上下反动菜单，直到看到 ``Restart Bootloader`` 菜单，然后就按下 ``电源键`` 确认

Pixel 3 lock bootloader
-------------------------

- 在USB链接的电脑端，执行命令::

   fastboot flashing lock ``Fastboot Mode`` 

- 然后通过 ``音量键`` 上下反动菜单，直到看到 ``Restart Bootloader`` 菜单，然后就按下 ``电源键`` 确认

- 在USB链接的电脑端，执行命令::

   fastboot flashing lock

此时终端显示::

   OKAY [  0.161s ]
   Finished. Total time: 0.161s

手机端提示::

   If you lock the bootloader, you will not be able to install custom operating system software on this phone.

此时bootloader没有锁定的警告消失，证明锁定成功。

参考

重新lock bootloader
====================

无锁的bootloader是一个高风险状态，如果没有必要，可以重新lock住bootloader

Pixel 3 bootloader mode
------------------------

- 对于 :ref:`pixel_3` ，首先关机，然后安装 ``电源键`` 和 ``音量降低键`` 开机

- 此时进入 ``Fastboot Mode`` 

- 然后通过 ``音量键`` 上下反动菜单，直到看到 ``Restart Bootloader`` 菜单，然后就按下 ``电源键`` 确认

Pixel 3 lock bootloader
-------------------------

- 在USB链接的电脑端，执行命令::

   fastboot flashing lock ``Fastboot Mode`` 

- 然后通过 ``音量键`` 上下反动菜单，直到看到 ``Restart Bootloader`` 菜单，然后就按下 ``电源键`` 确认

- 在USB链接的电脑端，执行命令::

   fastboot flashing lock

此时终端显示::

   OKAY [  0.161s ]
   Finished. Total time: 0.161s

手机端提示::

   If you lock the bootloader, you will not be able to install custom operating system software on this phone.

此时bootloader没有锁定的警告消失，证明锁定成功。

参考
=======

- `How to Unlock Your Android Phone’s Bootloader, the Official Way <https://www.howtogeek.com/239798/how-to-unlock-your-android-phones-bootloader-the-official-way/>`_
- `Understanding the risks of having an unlocked bootloader <https://forum.xda-developers.com/t/info-understanding-the-risks-of-having-an-unlocked-bootloader.1898664/>`_
- `Bootloader Mode GOOGLE Pixel 3, how to <https://www.hardreset.info/devices/google/google-pixel-3/bootloader-mode/>`_
