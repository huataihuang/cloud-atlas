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

再次改进HTTPS访问
----------------------

我在实践 :ref:`calibre-web_kobo` 时发现，如果简单配置 ``api_endpoint`` 使用 ``http://YOUR_DOMAIN_OR_IP/kobo/xxxxxxxxxxxxxxxxx`` 似乎存在连接问题。gemini提示新版本kobo可能强制使用了https访问，所以需要调整上述配置，将 Calibre-backend 和 Calibre-web 都采用HTTPS。

.. note::

   由于是两个服务，最优雅的方式是使用域名来区分，让nginx基于域名访问SNI来区分反向代理的目标。不过，我的homelab实际上还没有部署本地DNS，所以在这里暂时采用端口来区分不同服务。

.. warning::

   这段实践确实完成了HTTPS部署的 ``nginx-ingress`` ，部署方法可以作为后续迭代改进的参考。但是，依然没有解决 :ref:`kobo_libra_h2o` 访问自建Calibre书库的问题，因为我发现Kobo根本就没有访问NGINX服务。这里有一个推测是这个 :ref:`calibre-web_kobo` 同步功能需要先激Kobo电子阅读器的“书城”功能。但是，在中国大陆Kobo电子书尝试登录书城会提示所在地区不在服务范围(被官方屏蔽了)，我参考gemini使用了 :ref:`sqlite` 强制插入数据库记录，但是看起来没有效果

- ``docker-compose.yml`` :

.. literalinclude:: linuxserver_docker-calibre-web/docker-compose_https.yml
   :caption: 调整https反向代理后端不同端口的docker-compose.yml

- ``nginx/conf.d/calibre.conf`` :

.. literalinclude:: linuxserver_docker-calibre-web/calibre_https.conf
   :caption: 调整2个服务反向代理nginx配置 nginx/conf.d/calibre.conf

需要注意上述配置中的一些调整点：

- 单独建立了一个 ``calibre-network`` 的bridge网络，这个网络仅用于连接 ``nginx-ingress`` / ``calibre-backend`` / ``calibre-web`` ，可以隔离其他容器的网络

  - 如果以后要和其他容器网络互通，则可以调整 ``dirver: bridge`` 改为 ``driver: overlay`` 或Macvlan直接分配的物理局域网IP
  - 这种 **显式声明网络** 可以配置为 ``external: true`` (外部预建网络)，这样网络就便横一个常驻的内网总线，即使容器销毁，网络依然留存，随时等待新容器挂载
  - 独立网络默认随机分配IP网段(例如 ``172.17.0.0/16`` )，通常和局域网网段有一定概率重合。这种显式声明网络可以独立配置指定的内网私有子网，防止网段冲图:

.. literalinclude:: linuxserver_docker-calibre-web/networks.yml
   :caption: 独立网段配置

- 只有 ``nginx-ingress`` 通过 ``ports:`` 配置映射了Host主机的端口，也就是只有这个容器对外提供服务，并通过反向代理访问 ``nginx-backend`` 和 ``calibre-web``
- ``restart: always`` 方式确保容器始终启动，避免偶然stop之后没有随着操作系统启动而启动

在nginx配置中有如下调整:

- ``proxy_set_header Host $http_host;`` 取代了 ``proxy_set_header Host $host;`` :

  - 在绝大多数情况下的上述两个配置行为是一样的，但在非标准端口（比如当前使用的 8080 和 8083）的物理拓扑下，它们有着决定性的区别:

    - $host（不带端口）：只包含客户端请求的域名或 IP 地址。例如客户端访问 https://192.168.1.9:8083/ ，Nginx 传给后端的 Host 头部纯粹是 192.168.1.9。
    - $http_host（带端口）：直接原封不动地透传客户端浏览器发来的 Host 请求头，包含物理端口号。例如传递过去的是 192.168.1.9:8083。

  - 这里改成 ``$http_host`` 非常关键，因为如果继续使用 ``$host`` 则反向代理只传递主机信息，Calibre-web收到的请求只会看到访问 192.168.1.9 ，就会以为自己运行在标准的443端口，从而生成类似 https://192.168.1.9/v2/synctoken... 这样的错误下载连接(漏掉了 ``:8083`` )，这会导致客户端下载报错哦: **非标准端口的反向代理拓扑中，必须使用 $http_host** 这样才能提供端口号

使用
=======

访问 ``http://<你的服务器IP>:8083`` 初次默认管理员账号：``admin`` ，默认初始密码： ``admin123`` 务必第一时间进入设置修改默认密码。

参考
======

- `GitHub: linuxserver/docker-calibre-web <https://github.com/linuxserver/docker-calibre-web>`_
