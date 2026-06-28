.. _linuxserver_docker-calibre_usb_kobo:

=========================================
linuxserver/calibre容器通过USB同步kobo
=========================================

我在 :ref:`linuxserver_docker-calibre-web` 实践中尝试通过内置的 ``Kobo Sync`` 功能来实现 :ref:`kobo_libra_h2o` 书籍同步，但是似乎由于书城功能无法激活而失败。所以我退而求其次，想要通过USB线直连方式进行书籍同步。

由于是在Linuxserver容器中运行 ``calibre-backend`` ，底层是全功能的Udev和Mnt挂载机制，所以方法是透传Kobo设备(对Linux系统显示为 ``/dev/sda`` 磁盘):

- 首先确认在Host主机上连接的Kobo设备对应的块设备:

.. literalinclude:: linuxserver_docker-calibre_usb_kobo/sda
   :caption: 检查确认 /dev/sda 设备文件权限和主次设备号

- 修改 ``docker-compose.yml`` 透传设备:

  - ``devices`` : 将Host主机的 ``/dev/sda`` 映射为容器内的 ``/dev/sda``
  - ``privileged: true`` (特权模式): 由于容器默认没有物理主机的 ``mount`` （挂载）内核特权，如果不放开权限，Calibre 内部的 Linux 系统在执行挂载时会报 ``Permission Denied`` 。直接开启 privileged（特权模式）设置比较简单

.. literalinclude:: linuxserver_docker-calibre-web/docker-compose_https.yml
   :caption: 透传 ``/dev/sda`` 设备到容器内部
   :lines: 21-40
   :emphasize-lines: 5-7

- 重建 ``calibre-backend`` 容器是配置生效:

.. literalinclude:: linuxserver_docker-calibre_usb_kobo/restart
   :caption: 重建 ``calibre-backend`` 容器

``docker-compose.yml`` 配置在 :ref:`linuxserver_docker-calibre_gpu` 按照gemini建议，上述 ``privileged: true`` 在新的 Linux 内核或 Docker 运行时（Runtime）中可能无法继承宿主机的 **虚拟终端控制台（TTY）和共享内存（/dev/shm）** ，所以调整增加 ``ipc: host`` ，以便能够继承主机的IPC内存总线

另外，虽然 ``privileged: true`` 是一种简单粗暴的开启容器特权的方法，但是这个方法使得容器能够完全访问物理主机的资源，破坏性极大非常不安全。所以，建议关闭 ``privileged: true`` ，而采用单独添加 ``cap_add`` 添加必要的权限。

.. warning::

   不过，我的实践 关闭 ``privileged: true`` ，而采用单独添加 ``cap_add`` 添加必要的权限 似乎遇到问题::

      mount: /media/kobo: cannot mount /dev/sda read-only.
      dmesg(1) may have more information after failed mount system call.

   检查 dmesg ::

      printk: dmesg (106582): Attempt to access syslog with CAP_SYS_ADMIN but no CAP_SYSLOG (deprecated).

   所以我还是回滚使用 ``privileged: true``

- 由于 ``linuxserver/calibre`` 容器内桌面环境不会想常规Ubuntu自动挂载磁盘，所以需要进入容器内部手工创建挂载点:

进入容器内部:

.. literalinclude:: linuxserver_docker-calibre_usb_kobo/exec
   :caption: 进入容器内部

在容器内部创建挂载目录( ``/media/kobo`` )

.. literalinclude:: linuxserver_docker-calibre_usb_kobo/mount
   :caption: 创建挂载目录并挂载

.. note::

   一定要确保 ``/dev/sda`` 挂载采用 Calibre 进程的属主 ``abc`` 能够访问的方式挂载(abc用户的UID=1000,GID=1000)，否则Calibre在执行 ``Connect to folder`` 会提示报错 ``Error communicating with device`` : 因为对设备目录没有写权限。

为方便执行，可以直接在Host主机上执行一条命令完成上述工作

.. literalinclude:: linuxserver_docker-calibre_usb_kobo/exec_mount
   :caption: 一条命令完成挂载

.. note::

   我最初以为这种手工创建目录和挂载目录不能自动触发Calibre发现设备，需要执行下面的 ``Connect to folder`` 步骤。但是实践发现，只要执行了上述目录创建和挂载，Calibre就自动识别出了Kobo设备，就可以进行设备管理(自动出现设备按钮)

- (废弃)  :strike:`由于是通过Linux命令行挂载，Calibre的GUI界面无法通过底层USB自动弹窗显示"已连接Kobo设备"` ，所以需要使用Calibre的 ``Connect to folder`` (连接到文件夹)功能，效果和插入USB电子书是一样的:

  - 通过浏览器访问 https://192.168.1.9:8080 介入Calibre桌面
  - 在工具栏，点击 ``Connect/Share`` 按钮，并在下拉菜单中选择 ``Connect to folder`` (连接到文件夹)
  
    - 在文件浏览器中，定位到刚才创建的 ``/media/kobo`` 目录，点击确认
    - :strike:`勾选 "Connect as device"`
    - :strike:`选择对应的电子书设备 "kobo Libre H20"`

- 完成电子书管理之后，一定要将挂载卸载，然后再拔出kobo设备

.. literalinclude:: linuxserver_docker-calibre_usb_kobo/exec_umount
   :caption: 卸载挂载才能拔出kobo设备

- 为了方便使用，可以建立alias，即修订 ``~/.bashrc`` 添加:

.. literalinclude:: linuxserver_docker-calibre_usb_kobo/alias
   :caption: 建立alias

改进: 采用host挂载kobo，然后映射进容器
==========================================

上述在容器内部直接挂载目录有一个非常大的缺陷是需要将磁盘设备透传进容器，并且赋予容器极大的权限，这不仅存在安全隐患，而且一旦物理上kobo被拔出，容器内的挂载点会直接变成死锁状态(D状态进程)，整个 ``calibre-backend`` 会卡死，甚至无法终止。

更好的办法是在Host物理主机上挂载目录 ``/mnt/kobo`` ，然后映射到容器内部使用，这就不必给容器赋予危险的权限

- 在Host主机上执行目录挂载设置 ``mount-kobo`` alias:

.. literalinclude:: linuxserver_docker-calibre_usb_kobo/mount_host
   :caption: 目录挂载设置 ``~/.bashrc``

挂载完成后，修订 ``docker-compose.yml`` 只需要映射目录就可以:

.. literalinclude:: linuxserver_docker-calibre_usb_kobo/volumes.yml
   :caption: 映射目录
