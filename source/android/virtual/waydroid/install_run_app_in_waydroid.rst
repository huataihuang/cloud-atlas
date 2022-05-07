.. _install_run_app_in_waydroid:

===================================
在WayDroid中安装和运行Android应用
===================================

在完成了 :ref:`install_waydroid` 之后，可以安装和运行Anroid应用。以下我的实践是安装和运行DingTalk

- 首先检查waydroid状态::

   waydroid status

输出应该类似::

   Session:        RUNNING
   Container:      RUNNING
   Vendor type:    MAINLINE
   Session user:   huatai(1000)
   Wayland display:        wayland-0

如果显示 ``session`` 没有运行::

   Session:        STOPPED
   Vendor type:    MAINLINE

则运行以下命令::

   waydroid session start

- 安装应用::

   waydroid app install xxxx.apk

同时错误::

   [19:58:32] Failed to get service waydroidplatform, trying again...
   [19:58:33] Failed to get service waydroidplatform, trying again...
   ...

按下 ``ctrl-c`` 可以看到报错实际上是 ``/usr/lib/waydroid/tools/interfaces/IPlatform.py`` ::

   def get_service(args):
       helpers.drivers.loadBinderNodes(args)
       serviceManager = gbinder.ServiceManager("/dev/" + args.BINDER_DRIVER)
       tries = 1000
   
       remote, status = serviceManager.get_service_sync(SERVICE_NAME)
       while(not remote):
           if tries > 0:
               logging.warning(
                   "Failed to get service {}, trying again...".format(SERVICE_NAME))
               time.sleep(1)
               remote, status = serviceManager.get_service_sync(SERVICE_NAME)
               tries = tries - 1
           else:
               return None
   
       return IPlatform(remote)

看来是检查 ``waydroidplatform`` 服务异常

排查
=========

- 执行 ``waydroid log`` 查看日至:

.. literalinclude:: install_run_app_in_waydroid/waydroid_log
   :language: bash

`Failed to get service waydroidplatform, trying again... #282 <https://github.com/waydroid/waydroid/issues/282>`_ 的一个方法，似乎是 python gbinder 软件包的问题，通过最新的gbinder-python来修复::

   sudo apt install devscripts dh-make

   git clone --single-branch --branch bullseye https://github.com/erfanoabdi/gbinder-python.git
   cd gbinder-python/
   sudo apt build-dep .
   dch --create --package "gbinder-python" --newversion "1.0.0~git20210909-1" foo bar
   dh_make --createorig -p "gbinder-python_1.0.0~git20210909"
   # Select "p" when prompted for the package type, leave the rest at the defaults
   debuild -us -uc
   cd ..
   sudo dpkg -i python3-gbinder_1.0.0~git20210909-1_arm64.deb

但问题还是没有解决

参考
======

- `Mobian Wiki: Waydroid <https://wiki.mobian.org/doku.php?id=waydroid>`_ 这篇文档提供了源代码编译和软件仓库直接安装两种方法，并且给出了问题修复的很多方法，有参考价值
