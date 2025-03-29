.. _ubuntu_hibernate_old:

==================================
Ubuntu Hibernate休眠(旧实践归档)
==================================

.. note::

   本文是以前的实践记录，有些杂乱，并且 ``uswsusp`` 已经在 Ubuntu 21.04 开始不再支持，所以重新实践和整理 :ref:`ubuntu_hibernate`

在 :ref:`ubuntu_on_mbp` 实现 :ref:`kvm_docker_in_studio` ，可以模拟出集群进行实践。在使用中，经常需要把笔记本携带在身边，每次都需要开关电脑，实际上就会不断重启虚拟机。对于恢复工作环境非常麻烦。

Linux支持 ``Suspend`` (挂起到内存) 和 ``Hibernate`` (挂起到磁盘) ，建议使用 ``Hibernate`` ，这样可以把内存中数据完全存储到磁盘，就可以断开电源，也不会出现因电能不足而关机。

不过，Linux上到Hibernate实现起来有点曲折，我的实践：

- `fedora系统使用systemd设置Hibernate休眠 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/redhat/system_administration/systemd/hibernate_with_fedora_in_laptop.md>`_ 
- `Gentoo系统的suspend和hibernate休眠 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/gentoo/suspend_hibernate.md>`_
- `Ubuntu系统hibernate休眠 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/ubuntu/system_administration/ubuntu_hibernate.md>`_

.. note::

   我在实现Hibvernate上可能走了弯路，也许用默认的 ``swsusp`` 可能更简单些（但是我只测试了 ``uswsusp`` ）。另外，我只解决了命令行休眠，集成到systemd的步骤没有实践成功。

内核和驱动准备（关键）
=========================

.. note::

   之前花费了一周时间反复折腾MacBook Pro上的Hibernate(save to disk)，总是发现恢复时异常死机或者图形界面无响应，最后总结经验如下:

   - 显卡驱动需要从默认 ``nouveau`` 替换成Nvidia闭源驱动
   - 内核传递参数 ``acpi_osi=Windows`` 避免BIOS访问操作系统不支持的ACPI特性

   详细记录见 `Ubuntu系统hibernate休眠 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/ubuntu/system_administration/ubuntu_hibernate.md>`_

- 修改 ``/etc/default/grub`` 设置BIOS标示( ``acpi_osi`` )系统为Windows避免MacBook Pro查询系统不支持的Darwin特性::

   #GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
   GRUB_CMDLINE_LINUX_DEFAULT="text"
   GRUB_CMDLINE_LINUX="ipv6.disable=1 acpi_osi=Windows"

.. note::

   启动内核text模式以便查看系统启动信息，关闭IPv6是避免无线网卡驱动触发不支持IPv6特性Segment Fault

.. note::

   参考`archLinux的Mac Power management段落 <https://wiki.archlinux.org/index.php/mac#Power_management>`_ 也可以设置 ``acpi_osi=!Darwin`` 内核参数告知firmware系统是不兼容macOS，这样在Mac尚会禁用Thunderbolt adapter，可以极大降低电力消耗。我在 :ref:`reduce_laptop_overheat` 中采用了禁用thunderbolt 模块的方法。

- 执行更新grub::

   sudo update-grub

- 安装Nvidia驱动::

   sudo apt install ubuntu-drivers-common
   ubuntu-drivers devices
   sudo ubuntu-drivers autoinstall

- 重启系统，重启后使用 ``lspci -vvv`` 检查确保显卡设备使用了Nvidia驱动。并使用 ``lsmod | grep nouveau`` 检查确保没有加载 ``nouveau`` 内核模块

- 卸载 ``nouveau`` 相关Xorg软件包（可选）::

   sudo apt --purge remove xserver-xorg-video-nouveau
   sudo apt autoremove

测试Ubuntu Hibernate
==================================

- 检查内核是否支持Hibernate::

   cat /sys/power/state

输出中包含 ``disk`` 就表明支持Hibernate，例如::

   freeze mem disk

要验证当前系统是否已经支持Hibernate，只需要执行如下命令::

   sudo systemctl hibernate

如果系统能够自动保存所有当前状态，并且在按下电源键自动恢复原先的工作状态则表明已经支持了hibernate。不过，很不幸，默认的系统验证下来是直接关机了。

创建Hibernate使用的swap文件
==============================

在hibernate状态（HTD或ACPI S4）主机的状态需要写入磁盘，这样就无需电力维持。这个状态是通过写入swap分区或swap文件实现的。

.. warning::

   不要在BTRFS上尝试使用swap文件，这会导致文件系统损坏！！！

swap分区或swap文件需要和RAM一样大小，或者至少 2/5的内存大小，参考 `About swap partition/file size <https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate#About_swap_partition.2Ffile_size>`_ 可以看到 ``/sys/power/image_size`` 设置了suspend-to-disk创建映像的大小，默认这个值设置的是内存的2/5大小。如果将数值 ``0`` 写入到 ``/sys/power/image_size`` 则系统会尽可能缩小suspend镜像。通过调整 ``/sys/power/image_size`` 你可以使得suspend镜像尽可能小，或者增加这个值以便hibernate处理速度更快。

.. note::

   这里建议可以设置swap分区至少 2/5 的内存大小是假设系统内存足够，这样一般情况下系统不会使用swap，所以就可以把所有swap都用于hibernate，也就是默认的 2/5 内存大小的swap应该也够用于保存内存状态。

实际我采用了 ``2/5 内存 + 2G`` 的swap大小，这是因为默认Ubuntu安装就设置了2G的swap文件，我再加上 2/5 的内存大小swap文件来做保障。我的笔记本是16G内存，所以，将原先2G的 ``/swapfile`` 改成 9G::

   swapoff /swapfile
   rm -f /swapfile

   sudo fallocate -l 9g /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile

.. note::

   在之前测试通过内核参数传递的 ``resume=`` 参数是指磁盘设备名，通常是磁盘swap分区。如果使用swap文件，则需要指定swap文件所在的磁盘分区，同时加上这个磁盘文件的物理偏移量（ ``physical_offset`` ）。这种内核参数传递方法，请参考我之前的测试:

   `Ubuntu系统hibernate休眠 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/ubuntu/system_administration/ubuntu_hibernate.md>`_

安装uswsusp
================

.. warning::

   从 Ubuntu 21.04 开始， ``uswsusp`` 已经被移除(不再支持)，只能使用标准的 ``systemctl`` 方式来完成 ( `uswsusp package has gone in Debian Bullseye <https://unix.stackexchange.com/questions/683217/uswsusp-package-has-gone-in-debian-bullseye>`_ )

   我的最新实践 :ref:`ubuntu_hibernate`

.. note::

   参考 `PowerManagement/Hibernate <https://help.ubuntu.com/community/PowerManagement/Hibernate>`_

   在Ubuntu系统，默认的hibernate是使用内核build的 ``swsusp`` ，而且 Gnome 和 ``pm-utils` 也使用这个方式（推荐使用 ``platform`` 如果BIOS支持问题，也可以改为 ``shutdown`` ）::
   
      sudo -s
      echo platform > /sys/power/disk
      echo disk > /sys/power/state
      
我在MacBook Pro上实践遇到恢复时图形界面无响应问题（排查最终是通过更换驱动和添加内核 ``acpi_osi`` 参数解决），所以改为采用了用户空间 ``uswsusp`` 。推测如果正确安装了驱动和设置了内核参数，使用默认的 ``swsusp`` 应该也是可以工作的。

- 安装用户空间软件suspend -- Userspace Software Suspend (uswsusp)::

   sudo apt install uswsusp

安装过程就会提示::

   The swap file or partition that was found in uswsusp's configuration file is not active. 
   In most cases this means userspace software suspend will not work as expected. You should choose another swap space.
   However, in some rare cases, this configuration may be intentional. 
   Continue without a valid swap space?

这里可以暂时回答Yes，因为我们下一步会进行配置。

配置uswsusp
=====================

- 验证Swap文件分区::

   sudo findmnt -no SOURCE,UUID -T /swapfile

输出显示::

   /dev/sda2 e5b8f8ad-b767-4719-8796-88eae998a056

.. note::

   在激活了 ``/swapfile`` 后，首次安装 ``uswsusp`` 工具包就会自动配置好 ``/etc/uswsusp.conf`` 配置文件::

      # /etc/uswsusp.conf(5) -- Configuration file for s2disk/s2both
      resume device = /dev/sda2
      compress = y
      early writeout = y
      image size = 7692818022
      RSA key file = /etc/uswsusp.key
      shutdown method = platform
      resume offset = 8617984

   这里的 ``resume offset = 8617984`` 是 ``uswsusp`` 自动计算出的，实际上使用 ``swap-offset /swapfile`` 也可以验证这个偏移量。

配置uswsusp（可选）
=====================

- (可选，如果安装时没有自动创建的话）创建 ``/etc/uswsusp.conf`` ，即执行::

   sudo dpkg-reconfigure -pmedium uswsusp

此时再次显示之前的提示::

   The swap file or partition that was found in uswsusp's configuration file is not active. 
   In most cases this means userspace software suspend will not work as expected. You should choose another swap space.
   However, in some rare cases, this configuration may be intentional. 
   Continue without a valid swap space?

这里选择：

- ``Yes`` 表示 ``Continue without a valid swap space?`` （此时Wizard还没有设置swap文件）
- 在下一个选择问题::

   To be able to suspend the system, uswsusp needs a swap partition or file to store a system snapshot. Please choose the device to use, from the list of suitable swap spaces, sorted by size (largest first).

   Swap space to resume from:

                              /swapfile1
                              /swapfile
                              /dev/disk/by-uuid/e5b8f8ad-b767-4719-8796-88eae998a056

注意：选择 swap 文件所在的 ``partition`` ，即之前的命令 ``findmnt`` 输出的内容， ``不要`` 选择swap文件自身。所以，我们这里选择最后一行 ``/dev/disk/by-uuid/e5b8f8ad-b767-4719-8796-88eae998a056``

- 在下一个页面中提问是否加密suspend内容（会影响速度）::

   For increased security, it is possible to encrypt the snapshot that is written to disk during suspend. On resume (and suspend if you don't use an RSA key), you will be prompted for a passphrase. Encryption adds a significant time to the suspend and resume processes.

   Encrypt snapshot?

安全要求不高，我选择默认 ``No`` 不加密

- 检查swap文件的 ``swap_id`` ::

   sudo -s swaplabel /swapfile

输出显示::

   UUID:  825fa235-e08c-441e-8637-57309d600ad6

- 创建文件 ``/etc/initramfs-tools/conf.d/resume`` 加入 ``swap_id`` ::

   echo "RESUME=UUID=825fa235-e08c-441e-8637-57309d600ad6" > /etc/initramfs-tools/conf.d/resume

   update-initramfs -u

- 测试Hibernate::

   sudo s2disk

此时看到屏幕一闪进入终端模式，并显示在保存image。保存过程结束后，笔记本关机。再次按下电源按钮，会有一个image恢复过程，然后就会恢复到之前的图形界面。

集成uswsusp到pm-utils
=========================

.. note::

   需要安装 ``apt install pm-utils`` ( 依赖安装 ``ethtool pm-utils vbetool`` )

   推荐使用 ``pm-hibernate`` 是因为gnome的默认hibernate是通过pm-hibernate实现的。

- 编辑 ``/etc/pm/config.d/00sleep_module`` ::

   SLEEP_MODULE="uswsusp"
   
- 测试::

   sudo tail -f /var/log/pm-suspend.log &
   sudo pm-hibernate

在系统休眠之后，按下电源开关恢复，可以看到屏幕字符终端显示恢复保存的镜像，确保正确恢复图形工作洁面后，再进行下一步集成systemd操作。

集成systemd
=================

.. note::

   目前只在字符界面测试成功，但是在图形界面测试遇到恢复后黑屏问题，所以暂时放弃图形界面改为启动后直接进入字符终端界面。

``systemd-suspend.service`` 是一个系统服务，通过 ``suspend.target`` 拉取并响应实际的系统挂起。同样， ``systemd-hibernate.service`` 则是有 ``hibernate.target`` 拉取并执行相应的hibernate。

在进入系统 syspend 和/或 hibernation 之前，systemd会执行所有在 ``/usr/lib/systemd/system-sleep/`` 目录下的可执行文件并传递2个参数给这些程序。第一个参数是 ``pre`` ，第二个参数是根据选择的动作传递 ``suspend`` ， ``hibernate`` , ``hybrid-sleep`` 或 ``suspend-then-hibernate`` 。而当系统离开 ``suspend`` 和/或 ``hibernate`` 之前，会执行相同的目录下的可执行程序，只不过第一个参数被改成了 ``post`` 。所有在这个目录下的可执行程序是并发执行的，并且只有所有的可执行程序执行完毕之后，才会继续动作。

注意在 ``/usr/lib/systemd/system-sleep/`` 目录下的脚本或程序倾向于本地使用并且可以hack。如果应用程序想要重新执行系统 suspend/hibernation 并恢复，则应该使用 `Inhibitor interface <https://www.freedesktop.org/wiki/Software/systemd/inhibit>`_ 。

- 编辑 ``hibernate`` 服务::

   sudo systemctl edit systemd-hibernate.service

粘贴以下代码::

   [Service]
   ExecStart=
   ExecStartPre=-/bin/run-parts -v -a pre /lib/systemd/system-sleep
   ExecStart=/usr/sbin/s2disk
   ExecStartPost=-/bin/run-parts -v --reverse -a post /lib/systemd/system-sleep

.. note::

   注意在Ubuntu 18.04及以上版本中， ``pre/post`` 脚本位于 ``/lib/systemd/system-sleep`` 目录，和一些介绍debian的文档中设置 ``/usr/lib/systemd/system-sleep`` 不同。错误指向目录的话会导致休眠唤醒之后，图形界面始终是黑屏（虽然系统依然可以ssh登陆和使用）。

   ``不过，这个集成systemd的步骤我测试没有成功，目前只能使用命令行pm-hibernate完成休眠``

- 更新systemd::

   sudo systemctl daemon-reload

- 测试运行::

   sudo systemctl hibernate

笔记本合上屏幕休眠
---------------------

笔记本合上屏幕的时候会触发systemd事件，所以通过修改 ``/etc/systemd/logind.conf`` 如下可以在合上屏幕时进入hibernate而不是默认的suspend::

   #HandleLidSwitch=suspend
   HandleLidSwitch=hibernate

然后重新加载 ``systemd-logind`` 生效::

   sudo systemctl restart systemd-logind

.. note::

   现在在字符终端界面合上笔记本屏幕会自动休眠，然后也能够恢复运行。不过目前图形界面尚未解决问题。

激活图形界面hibernate
=================================

.. note::

   由于集成systemd步骤在图形界面测试未成功，所以此步骤也没有成功。

- 创建 ``/etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla`` ::

   [Re-enable hibernate by default in upower]
   Identity=unix-user:*
   Action=org.freedesktop.upower.hibernate
   ResultActive=yes
   
   [Re-enable hibernate by default in logind]
   Identity=unix-user:*
   Action=org.freedesktop.login1.hibernate;org.freedesktop.login1.handle-hibernate-key;org.freedesktop.login1;org.freedesktop.login1.hibernate-multiple-sessions;org.freedesktop.login1.hibernate-ignore-inhibit
   ResultActive=yes

然后重启系统就可以看到图形界面菜单显示了 ``Hibernate`` 功能。不过，这个功能我测试返回还是需要 ``systemd-hibernate.service`` 支持，否则也是黑屏（虽然可以ssh访问）

参考
=========

- `How can I hibernate on Ubuntu 16.04? <https://askubuntu.com/questions/768136/how-can-i-hibernate-on-ubuntu-16-04>`_ 其中最重要的一个解决方案是 "Hibernation using systemctl and getting it working in tough cases" ，在这篇问答的第2个回答中。
- `PowerManagement/Hibernate <https://help.ubuntu.com/community/PowerManagement/Hibernate>`_
- `Enable hibernate on Ubuntu using uswsusp (s2disk) <https://medium.com/@lzcoder/enable-hibernate-on-ubuntu-using-uswsusp-s2disk-ae0b71862eb5>`_
- `systemd-suspend.service <https://www.freedesktop.org/software/systemd/man/systemd-suspend.service.html>`_
