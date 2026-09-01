.. _macports_on_mavericks:

=============================
在Mavericks上使用Macports
=============================

安装
=====

:ref:`macports` 提供了各种macOS版本对应的安装包，也包括Mavericks(OS X 10.9)。但是，在2026年 :ref:`mavericks_mba11_late_2010` 安装Macports会遇到一个问题，安装过程卡在 "Running package scripts..."一直不动。

其实此时软件包已经基本安装完成了，但是后台执行post-install脚本，尝试连接已经关停的旧版MacPorts服务器卡死...

快捷的解决方法是强行结束卡死的脚本:

.. literalinclude:: macports_on_mavericks/kill
   :caption: 强行结束脚本

此时会提示安装失败，不过可以看到 ``/opt/local/bin/port`` 实际已经安装好

不过，为了能够更好安装，还是重新开始离线安装比较好:

- 清理残留文件:

.. literalinclude:: macports_on_mavericks/clean
   :caption: 清理残留文件

- 断开网络，关闭Wifi连接

－重新运行 ``MacPorts-2.12.6-10.9-Mavericks.pkg``

- 此时会顺利完成安装，然后检查 ``port`` 是否位于路径中可以访问

同步
======

虽然Macportsgu安放文档说安装以后第一件事是执行以下命令同时升级程序自身(Base)和更新本地Ports软件树(Portfile定义):

.. literalinclude:: macports_on_mavericks/selfupdate
   :caption: 同时更新程序和Ports软件树

但是对于Mavericks(OS X 10.9)，如果更新MacPort Base源码，由于最新的MacPorts源码大量使用了现代macOS SDK和C++17特性，10.9自带的古老的Xcode 6.2(Clang)在编译新版Base会大量报错直接导致MacPorts损坏不可用。

所以，实际在Mavericks上采用如下命令，仅同步Ports软件树，完全不检查和更新MacPorts程序本身:

.. literalinclude:: macports_on_mavericks/sync
   :caption: 仅同步Ports软件树

.. note::

   MacPorts同步配置文件是 ``/opt/local/etc/macports/sources.conf`` ，最后一行指明了同步文件内容:

   .. literalinclude:: macports_on_mavericks/sources.conf
      :caption: 同步文件的配置

   注意这里一定指定了同步文件，并且有一个 ``[default]`` 配置参数

   国内原先有清华和中科大镜像源，但是现在文件都没有了，所以还是得从官方下载。如果访问阻塞，可能需要梯子。

使用
======

- 搜索可以安装的软件

.. literalinclude:: macports_mpv_on_mavericks/search
   :caption: 搜索mpv

输出类似:

.. literalinclude:: macports_mpv_on_mavericks/search_output
   :caption: 搜索mpv的输出信息

- 安装

.. literalinclude:: macports_mpv_on_mavericks/install
   :caption: 安装mpv
