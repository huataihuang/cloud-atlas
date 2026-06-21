.. _linuxserver_docker-calibre-web:

===============================
linuxserver/colibre-web
===============================

``linuxserver/colibre-web`` 提供了易于浏览、阅读和狭隘现有 ``Calibre`` 数据库提供的电子书。我计划在 :ref:`linuxserver_docker-calibre` 部署之后结合使用，以实现一个较为完善的电子书网站。

安装
======

采用Docker Compose是比较简单方便的方法

初步运行
-----------

- 创建数据目录:

.. literalinclude:: linuxserver_docker-calibre-web/mkdir
   :caption: 创建数据目录

- 编写 ``docker-compose.yml`` 配置(该配置没有启用HTTPS，现在较新版本 :ref:`selkies` 已经强制采用HTTPS，所以实际访问无法打开桌面，必须改进增加HTTPS ):

.. literalinclude:: linuxserver_docker-calibre-web/docker-compose.yml
   :caption: 配置 ``docker-compose.yml``

改进HTTPS访问
----------------

由于 :ref:`linuxserver_docker-calibre` 直接访问 ``http://<服务器IP>:8080`` 提示报错必须改进为HTTPS访问，所以上述Docker Compose再增加 :ref:`nginx` 容器实现 :ref:`nginx_reverse_proxy_https`

- 创建数据目录:

.. literalinclude:: linuxserver_docker-calibre-web/mkdir_https
   :caption: 创建数据目录，增加nginx配置目录

- 使用OpenSSL创建自签名证书:

.. literalinclude:: linuxserver_docker-calibre-web/openssl
   :caption: 使用OpenSSL创建自签名证书

完成以后 ``certs`` 目录就有了 ``server.crt`` (公钥) 和 ``server.key`` (私钥)

- 编辑一个 **支持WebSokcet 的握手升级头（Upgrade Headers）** 的NGINX配置，这样就能够支持Selkies/KasmVNC 平台底层深度依赖 WebSocket（WS） 协议进行超低延迟的桌面画面广播: ``~/docs/calibre-suite/nginx/conf.d/calibre.conf``

.. literalinclude:: linuxserver_docker-calibre-web/calibre.conf
   :caption: ``~/docs/calibre-suite/nginx/conf.d/calibre.conf``

- 重新改写 ``docker-compose.yml`` :

.. literalinclude:: linuxserver_docker-calibre-web/docker-compose_https.yml
   :caption: 增加NGINX反向代理HTTPS的容器的 docker-compose.yml

.. note::

   - Compose设置了 ``depends_on`` 确保启动顺序
   - 后端数据库自动生成: ``calibre-backend`` 启动一个完整的Calibre运行环境，在初始化时候将数据目录修改为 ``/library`` 目录下初始化 ``metadata.db`` 核心数据库文件，就能和 Calibre-Web 共享目录
   - 前端无缝读取: 访问 ``http://<服务器IP>:8083`` 时WEB和后端共享物理目录，这样 Calibre-Web就能够直接访问后端生成的 ``metadata.db``
   - 特别增加一个 ``import`` 目录，因为Calibre支持一种自动导入功能，只要将自动导入目录指向这个 ``import`` 目录，这样就能将文件从后台复制到该目录下，然后系统就会自动导入Calibre书库，不需要人工干预

.. note::

   Calibre-Web 本质上是 Calibre 桌面端的 Web 前端，因此它的运行必须依赖一个由桌面端生成的初始化索引数据库文件 ``metadata.db``  。如果没有按照上文同时运行 Calibre-Web 和 Calibre，那么可以从官方下载一个空白的 ``metadata.db`` 模板存放到 ``books`` 目录

   .. literalinclude:: linuxserver_docker-calibre-web/metadata
      :caption: 下载空白的metadata.db

- 访问 ``https://<服务器IP>:8080`` 就能看到一个Calibre桌面客户端软件；访问 ``http://<你的服务器IP>:8083`` 就能看到Calibre Web界面

.. note::

   ``Calibre桌面`` 详见 :ref:`linuxserver_docker-calibre`

使用
=======

访问 ``http://<你的服务器IP>:8083`` 初次默认管理员账号：``admin`` ，默认初始密码： ``admin123`` 务必第一时间进入设置修改默认密码。

参考
======

- `GitHub: linuxserver/docker-calibre-web <https://github.com/linuxserver/docker-calibre-web>`_
