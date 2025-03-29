.. _grubby:

====================
grubby修改内核参数
====================

在做 :ref:`kernel` 内核参数配置时，例如 :ref:`ubuntu_grub` 采用修订 ``/etc/default/grub`` 配置文件，然后通过 ``update-grub`` 或者 ``grub2-mkconfig -o /boot/grub2/grub.cfg`` 完成内核参数修订 (包括 :ref:`redhat_linux` 也支持这种方式)。

不过，这种修订方式需要编辑配置文件，不适合通过脚本自动化完成海量服务器修订。(自己编写 ``sed`` 脚本虽然也能批量处理，但是通用性较差且容易误处理)所以， ``grubby`` 工具提供了读取Grub信息以及持久化修订 ``grub.cfg`` 的能力，可以完成批量处理 GRUB 2 配置文件，适合对生产环境海量服务器修订。

查看内核信息
==============

- 要找出系统默认启动内核执行::

   grubby --default-kernel

输出案例::

   /boot/vmlinuz-5.18.11-100.fc35.x86_64

- 查看默认内核的索引值::

   grubby --default-index

输出案例::

   0

这个索引值也就是对应前面 ``--default-kernel`` 的 ``/boot/vmlinuz-5.18.11-100.fc35.x86_64``

- 现在我们可以查看系统中有那些内核，并且找出其对应grub的索引值(这个索引值用于配置系统启动时加载的内核，见下文)::

   grubby --info=ALL

上述命令显示出所有内核以及配置项，例如在 ``z-dev`` 这个 :ref:`fedora` 系统::

   index=0
   kernel="/boot/vmlinuz-5.18.11-100.fc35.x86_64"
   args="ro console=ttyS0,115200"
   root="UUID=23fc0f61-894e-4b8e-a623-fb4290bb23e8"
   initrd="/boot/initramfs-5.18.11-100.fc35.x86_64.img"
   title="Fedora Linux (5.18.11-100.fc35.x86_64) 35 (Server Edition)"
   id="784e41a278df4e3e804b451ac3bb4c3e-5.18.11-100.fc35.x86_64"
   index=1
   kernel="/boot/vmlinuz-5.18.10-100.fc35.x86_64"
   args="ro console=ttyS0,115200"
   root="UUID=23fc0f61-894e-4b8e-a623-fb4290bb23e8"
   initrd="/boot/initramfs-5.18.10-100.fc35.x86_64.img"
   title="Fedora Linux (5.18.10-100.fc35.x86_64) 35 (Server Edition)"
   id="784e41a278df4e3e804b451ac3bb4c3e-5.18.10-100.fc35.x86_64"
   index=2
   kernel="/boot/vmlinuz-5.18.5-100.fc35.x86_64"
   args="ro console=ttyS0,115200"
   root="UUID=23fc0f61-894e-4b8e-a623-fb4290bb23e8"
   initrd="/boot/initramfs-5.18.5-100.fc35.x86_64.img"
   title="Fedora Linux (5.18.5-100.fc35.x86_64) 35 (Server Edition)"
   id="784e41a278df4e3e804b451ac3bb4c3e-5.18.5-100.fc35.x86_64"
   index=3
   kernel="/boot/vmlinuz-0-rescue-784e41a278df4e3e804b451ac3bb4c3e"
   args="ro console=ttyS0,115200"
   root="UUID=23fc0f61-894e-4b8e-a623-fb4290bb23e8"
   initrd="/boot/initramfs-0-rescue-784e41a278df4e3e804b451ac3bb4c3e.img"
   title="Fedora Linux (0-rescue-784e41a278df4e3e804b451ac3bb4c3e) 35 (Server Edition)"
   id="784e41a278df4e3e804b451ac3bb4c3e-0-rescue"

可以看到系统中有4个grub启动项，分别对应了4种内核。我们也可以看到默认启动的是索引 ``0`` 的内核 ``/boot/vmlinuz-5.18.11-100.fc35.x86_64``

- 可以指定查看某个内核的参数::

   grubby --info /boot/vmlinuz-5.18.11-100.fc35.x86_64

输出显示::

   index=0
   kernel="/boot/vmlinuz-5.18.11-100.fc35.x86_64"
   args="ro console=ttyS0,115200"
   root="UUID=23fc0f61-894e-4b8e-a623-fb4290bb23e8"
   initrd="/boot/initramfs-5.18.11-100.fc35.x86_64.img"
   title="Fedora Linux (5.18.11-100.fc35.x86_64) 35 (Server Edition)"
   id="784e41a278df4e3e804b451ac3bb4c3e-5.18.11-100.fc35.x86_64"

修订内核参数
===============

修订不同的启动内核
--------------------

- 如果需要回滚内核，例如将默认启动内核从 ``0`` 改为 ``1`` ::

   grubby --set-default-index 1

也可以直接指定内核::

   grubby --set-default /boot/vmlinuz-5.18.10-100.fc35.x86_64

修改内核参数
----------------

``grubby`` 提供了参数 ``--update-kernel`` 可以对指定内核或者所有内核的参数进行修改:

- ``--update-kernel=ALL`` 同时对所有内核的参数进行修订
- ``--update-kernel /boot/vmlinuz-5.18.11-100.fc35.x86_64`` 则对指定内核 ``/boot/vmlinuz-5.18.11-100.fc35.x86_64`` 进行参数修订

提供了2种内核参数修改方法:

- ``--args`` 添加或修改内核参数(如果能够匹配上现有内核参数就是修改)
- ``--remove-args`` 删除内核参数

举例::

   grubby --remove-args="rhgb quiet" --args=console=ttyS0,115200 --update-kernel /boot/vmlinuz-4.2.0-1.fc23.x86_64

完成后可以使用 ``--info`` 检查对应内核的参数::

   grubby --info /boot/vmlinuz-4.2.0-1.fc23.x86_64

上文也说了，如果 ``--args`` 参数匹配上了现有的内核参数，则是对现有参数进行修改，举例，修改内核串口参数比特率9660::

   grubby --args="console=ttyS0,9660" --update-kernel /boot/vmlinuz-5.18.11-100.fc35.x86_64

增加内核项
============

有时候我们需要验证同一个内核的不同内核参数，我们可以采用添加入口项方式。

- 例如，手工编译了一个新的 ``testing`` 内核，需要测试::

   grubby --add-kernel=/boot/vmlinuz-5.18.11-100.testing.x86_64 \
     --title="Fedora Linux (5.18.11-100.testing.x86_64)" \
     --initrd="/boot/initramfs-5.18.11-100.testing.x86_64.img" \
     --copy-default

使用 ``--copy-default`` 参数可以把现有系统的默认内核参数全部复制过来

- 例如，我们需要测试新的 ``testing`` 内核不同参数::

   grubby --add-kernel=/boot/vmlinuz-5.18.11-100.testing.x86_64 \
     --title="Fedora Linux (5.18.11-100.testing.x86_64) console 9660" \
     --initrd="/boot/initramfs-5.18.11-100.testing.x86_64.img" \
     --args="console=ttyS0,9660"

- 测试完成后可以删除内核项::

   grubby --remove-kernel=/boot/vmlinuz-5.18.11-100.testing.x86_64

参考
=======

- `12 practical grubby command examples (cheat sheet) <https://www.golinuxcloud.com/grubby-command-examples/>`_
- `Change default kernel using grubby Tool <https://dba010.com/2022/03/22/change-default-kernel-using-grubby-tool/>`_
- `Modify grub.cfg configurations on Linux using grubby <https://computingforgeeks.com/modify-grub-cfg-configurations-on-linux-using-grubby/>`_
- `Configuring GRUB 2 Using the grubby Tool <https://docs.fedoraproject.org/en-US/Fedora/23/html/System_Administrators_Guide/sec-Configuring_GRUB_2_Using_the_grubby_Tool.html>`_
