.. _linuxserver_docker-calibre:

===============================
linuxserver/calibre
===============================

``linuxserver/calibre`` 提供了易于部署的 ``Calibre`` 系统，容器化运行

我之前实践过 :ref:`alpine_install_calibre` ，并自己定制Docker镜像运行 ``calibre-server`` 。不过，LinuxServer.io 提供了标准化的镜像构建，其实用 :ref:`s6-overlay` 管理服务，可能更为易用。我准备后续在有时间精力情况下，再尝试实践。

此外， :ref:`linuxserver_docker-calibre-web` 提供了现代化界面的WEB浏览Calibre

安装
========

.. note::

   我的实践采用了结合 Calibre 和 Calibre-Web，所以统一采用Docker Compose来构建，安装方法同 :ref:`linuxserver_docker-calibre-web`

使用
=======

访问 ``http://<服务器IP>:8080`` 可以看到WEB页面的左侧显示是 :ref:`selkies` ，但是，如果没有配置HTTPS，则页面提示错误:

.. literalinclude:: linuxserver_docker-calibre/https_error
   :caption: 如果服务器没有配置HTTPS加密则无法访问桌面

最终解决方法是该经 :ref:`linuxserver_docker-calibre-web` 增加NGINX反向代理HTTPS

.. note::

   根据 :ref:`linuxserver_docker-calibre-web` 配置，Calibre 和 Calibre-Web 使用了 ``./library`` 作为共同的书籍存放目录，所以必须在初始化Calibre时候调整书籍目录到 ``/library`` 目录。

书籍导入
-----------

实际上Calibre的这个WEB桌面就相当于一个文件管理器，支持直接拖放电子书到浏览器窗口自动上传。不过，需要注意，自动上传到文件并没有导入书库，而是上传到了 ``/config/Desktop`` 目录下。

所以，还需要点击Calibre的 ``Add books`` 按钮找到 ``/config/Desktop`` 目录下上传的电子书进行导入。

书籍自动导入
-----------------

在 :ref:`linuxserver_docker-calibre-web` 的 ``docker-compose.yml`` 中，特意配置了一个 ``import`` 目录映射到Calibre容器中。因为Calibre有一个自动导入功能，可以监视某个目录，只要目录加入文件就自动导入Calibre书库:

- 点击 “首选项 (Preferences)” -> “添加书籍 (Adding books)” -> “自动导入 (Automatic importing)”
- 将目录精准指定为容器内部的 /import
- 点击 ``Apply`` 按钮生效

不过，我在实践中发现，scp到 ``import`` 目录的电子书并没有自动导入。似乎是 inode 通知功能有问题？

临时解决的方法是重启一次 ``calibre-backend`` ，每次重启会自动扫描 ``import`` 目录进行导入

另外一种方法是手工执行导入:

.. literalinclude:: linuxserver_docker-calibre/import
   :caption: 手工导入电子书

kobo支持
==============

开启kobo书城功能
-------------------

.. note::

   在设置kobo同步(原理是拦截了官方的书城同步，代之以自己创建的Calibre书库)之前，需要先激活Kobo电子书的书城功能。这个功能需要先配置Kobo电子书登录到官方书城才能显示出来，然后才能设置本段配置。

   不过这里有一个问题，就是kobo官方网站会提示你的地区不在服务范围，拒绝登录。所以，我实际采用了本段 :ref:`sqlite` 命令行插入记录方法

- 进入 ``.kobo`` 目录，先备份数据库:

.. literalinclude:: linuxserver_docker-calibre/backup
   :caption: 备份数据库

- 根据 ``.schema user`` 输出的字段，询问了gemini，提供了以下插入记录方法:

.. literalinclude:: linuxserver_docker-calibre/sqlite
   :caption: 插入记录

完成后检查 ``SELECT UserID, UserEmail, AuthToken FROM user;`` 输出显示:

.. literalinclude:: linuxserver_docker-calibre/sqlite_data
   :caption: 数据库记录

输入 ``.exit`` 退出 SQLite

- 在 Mac 上安全弹出 KOBO 盘符，拔掉数据线。长按 Kobo 顶部的物理电源键强制关机，再长按开机，迫使它的嵌入式 Linux 内核重新加载这份量身定制的数据库。

.. warning::

   似乎还有问题，我还没有解决同步的问题，gemini提示可能需要配置 https (采用nginx反向代理https)待实践

同步Calibre
----------------

- 通过浏览器访问 ``http://<服务器IP>:8083``
- 点击右上角的 “管理 (Admin)” -> “编辑基本配置 (Edit Basic Configuration)”
- 展开 “功能配置 (Feature Configuration)”，确认 “启用 Kobo 同步 (Enable Kobo Sync)” 已经勾选，并保存。
- 点击页面右上角你的 用户名（如 admin） 进去个人资料页，往下滚动
- 点击 ``Kobo Sync Token`` 下的 ``Create/View`` 按钮查看生成的token，会看到系统为你生成好了一串长长的 URL，格式通常为： ``http://<服务器IP>:8083/kobo/xxxxxxxxxxxxxxxxx``

由于Kobo官方没有直接提供 "自定义商城服务器" 输入框，需要通过修改Kobo的根目录下隐藏配置文件来注入地址:

- 使用数据线，将你的 Kobo 墨水屏连接到你的电脑
- 在 Kobo 屏幕上点击 “连接 (Connect)”，此时电脑上会挂载出一个普通的物理 U 盘
- 打开 Kobo 的磁盘根目录。关键点：Kobo 的系统配置目录是隐藏的：

  - 在 Mac 下，请在 Finder 窗口中按下快捷键 ``Command + Shift + .`` （点），此时会显影出半透明的隐藏文件夹
  - 进入名为 ``.kobo`` 的隐藏文件夹

- 找到一个叫 ``./kobo/Kobo/Kobo eReader.conf`` 的配置文件，像素级像素对齐地填入以下强制拦截变量:

.. literalinclude:: linuxserver_docker-calibre/eReader.conf
   :caption: 配置同步

- 保存修改的配置之后，安全弹出Kobo嗲字数，然后按

参考
======

- `GitHub: linuxserver/docker-calibre <https://github.com/linuxserver/docker-calibre>`_
