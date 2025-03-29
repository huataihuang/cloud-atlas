.. _alpine_bootloader:

==========================
Alpine Linux Bootloader
==========================

在Alpine Linux中，可以选择使用以下4种 ``bootloader`` :

- rEFInd
- Syslinux
- Grub
- EFI Boot Stub

.. warning::

   其实系统不使用bootloader也能启动，实际上 alpine linux 默认没有安装 bootloader (类似 :ref:`raspberry_pi_os` )，见下文。

.. note::

   我在 :ref:`alpine_install_pi_usb_boot` 还没有意识到 :ref:`pi_4` 默认firmware使用的是传统的BIOS模式，这导致不能满足服务器架构的ARM `SBBR <https://developer.arm.com/architectures/platform-design/server-systems#faq3>`_ ，出现 :ref:`pi_acpid_crashed` 现象。解决的方法是需要转换成 :ref:`pi_uefi_acpi` 。

   本文将分析 :ref:`alpine_linux` 所使用的不同Bootloader，为后续转换UEFI做准备。此外， :ref:`alpine_docker` 需要修订内核参数，也需要深入了解Bootloader。

rEFInd
===========

``rEFInd`` 提供了一个图形化方式EFI启动菜单，并且可以允许启动到能够找到的分区上的操作系统。我最早在MacBook安装多操作系统启动(macOS + Linux)时使用过这个工具，确实对于MacBook上切换操作系统比较方便。

- 安装 ``refind`` ::

   apt install refind  # 在debian/Ubuntu上安装refind
   refind-install --alldrivers  # 将refind安装到EFI分区，此时 --alldrivers 参数会为多个分区的操作系统准备启动项

在 ``/mdeia/sdXY`` (假设这是EFI分区)的配种加上默认启动Alpine::

   echo '"Alpine" "modules=loop,squashfs,sd-mod,usb-storage quiet initrd=\boot\intel-ucode.img initrd=\boot\amd-ucode.img initrd=\boot\initramfs-lts"' > /media/sdXY/boot/refind_linux.conf

.. _alpine_without_bootloader:

alpine不使用bootloader
=========================

我仔细检查了  :ref:`alpine_install_pi_usb_boot` 的系统，发现并默认并没有安装上述4种bootloader中的任何一个。但是系统只要设置了 ``/dev/sda1`` 是启动分区(并挂载到 ``/boot`` )就能够启动。

内核启动参数是通过 ``/media/sda1`` (启动分区)的根目录下 ``cmdline.txt`` 配置的:

我是怎么看出来的呢？

- ``cat /proc/cmdline`` 的内容是::

   coherent_pool=1M 8250.nr_uarts=0 snd_bcm2835.enable_compat_alsa=0 snd_bcm2835.enable_hdmi=1 bcm2708_fb.fbwidth=0 bcm2708_fb.fbheight=0 bcm2708_fb.fbswap=1 smsc95xx.macaddr=DC:A6:32:C5:48:9C vc_mem.mem_base=0x3eb00000 vc_mem.mem_size=0x3ff00000  modules=loop,squashfs,sd-mod,usb-storage quiet console=tty1 root=/dev/sda2

- ``/media/sda1/cmdline.txt`` 内容是::

   modules=loop,squashfs,sd-mod,usb-storage quiet console=tty1 root=/dev/sda2

可以看到上述 ``/media/sda1/cmdline.txt`` 内容就是内核参数的最后一部分，所以在 :ref:`alpine_docker` 中配置内核参数需要修订的是 ``/media/sda1/cmdline.txt`` 而不是 ``/media/sda1/boot/cmdline.txt`` (是 ``/boot`` 软连接到 ``/media/sda1/boot`` )。

这块内容和我之前在 :ref:`alpine_install_pi_usb_boot` 操作有关，我感觉当时没有仔细检查 ``添加 sda2 分区作为系统分区`` 操作时的分区内容。有待后续再次实践时验证。

参考
=======

- `alpine linux wiki: Bootloaders <https://wiki.alpinelinux.org/wiki/Bootloaders>`_
