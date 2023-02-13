.. _nginx_webdav:

====================
NGINX WebDAV服务器
====================

安装NGINX及支持WebDAV模块
==========================

:ref:`ubuntu_linux`
-----------------------

- 对于Ubuntu执行以下安装NGINX以及支持WebDAV模块:

.. literalinclude:: nginx_webdav/ubuntu_install_nginx_webdav
   :language: bash
   :caption: Ubuntu安装NGINX及WebDAV模块

- 检查 ``ngnix -V`` 输出:

.. literalinclude:: nginx_webdav/check_ubuntu_nginx_webdav
   :language: bash
   :caption: 检查Ubuntu安装NGINX及WebDAV模块

:ref:`macos`
----------------

- macOS中使用 :ref:`homebrew` 安装NGINX默认已经支持 webDAV ，以下是 :ref:`macos_studio` 安装工具软件命令:

.. literalinclude:: ../../apple/macos/homebrew/brew_install
   :language: bash
   :caption: 在macOS新系统必装的brew软件
   :emphasize-lines: 2

不过，默认 :ref:`homebrew` 安装的NGINX只提供了 ``--with-http_dav_module`` 支持，但是没有 ``http_ext_module`` 支持，这会导致 ``nginx.conf`` 配置中::

   dav_ext_methods PROPFIND OPTIONS;

无法识别，启动nginx时日志提示::

   2023/02/13 16:31:56 [emerg] 29049#0: unknown directive "dav_ext_methods" in /usr/local/etc/nginx/nginx.conf:52

这个问题必须解决，否则在 :ref:`joplin_sync_webdav` ，WebDAV客户端执行 ``MKCOL`` / ``PROPFIND`` 会报错返回 ``405`` 返回码

配置WebDAV
===============

.. _macos_nginx_webdav_joplin:

为Joplin配置WebDAV同步数据( :ref:`homebrew` )
-----------------------------------------------

.. note::

   本段实践为 :ref:`joplin_sync_webdav` 提供支持，在 :ref:`macos` 上采用 :ref:`homebrew` 提供的NGNIX

- :ref:`macos` 平台没有采用 :ref:`linux` 的PAM认证，采用 :ref:`nginx_basic_auth` 的密码文件认证:

.. literalinclude:: nginx_webdav/create_htpasswd
   :language: bash
   :caption: 创建NGINX的HTTP认证文件

- :ref:`homebrew` 提供的NGIX配置 ``/usr/local/etc/nginx/nginx.conf`` ( ``brew`` 安装的NGINX位置可能不同 ) 添加如下段落(我的NGINX监听 ``8080`` 端口)

.. literalinclude:: nginx_webdav/brew_nginx.conf
   :language: bash
   :caption: 配置NGINX支持WebDAV( :ref:`homebrew` 提供的NGINX没有支持第三方 `nginx-dav-ext-module <https://github.com/arut/nginx-dav-ext-module>`_ 所以不能启用 ``dav_ext_methods`` 指令，实践发现无法支持joplin同步)
   :emphasize-lines: 17,20,22-24,31-32

- 重启 NGINX 服务::

   brew services restart nginx

- 在 ``/Users/huatai/docs/joplin`` 目录下存放一个 ``test_webdav.txt`` 文件，然后执行不带密码的访问方式:

.. literalinclude:: nginx_webdav/curl_webdav_without_password
   :language: bash
   :caption: 不使用密码执行curl访问WebDAV测试

提示没有认证的报错:

.. literalinclude:: nginx_webdav/curl_webdav_without_password_output
   :language: bash
   :caption: 不使用密码执行curl访问WebDAV测试显示认证错误
   :emphasize-lines: 1

- 改为提供密码账号方式访问:

.. literalinclude:: nginx_webdav/curl_webdav_with_password
   :language: bash
   :caption: **使用密码** 执行curl访问WebDAV测试

此时提示信息显示认证通过，返回 ``200`` :

.. literalinclude:: nginx_webdav/curl_webdav_with_password_output
   :language: bash
   :caption: **使用密码** 执行curl访问WebDAV测试显示正确返回结果

去掉上述 :ref:`curl` 命令的 ``-I`` 参数，就能看到终端返回 ``test_webdav.txt`` 内容::

   Hello WebDAV

然后就可以测试 :ref:`joplin_sync_webdav`

异常排查
---------

- 启动同步后， ``Joplin`` 同步提示错误:

.. literalinclude:: nginx_webdav/joplin_sync_error
   :caption: Joplin同步报错显示405错误(Method Not Allowed)

- 检查 NGINX 的 ``access.log`` 日志:

.. literalinclude:: nginx_webdav/joplin_sync_nginx_access.log
   :caption: Joplin同步报错时NGINX的access.log日志
   :emphasize-lines: 5-10

可以看到 ``405`` 返回码对应的指令是 ``MKCOL`` 和 ``PROPFIND`` ，这说明配置中，以下模块选项配置是非常重要的::

   dav_ext_methods PROPFIND OPTIONS;

注意，在这个配置前面有一行::

   dav_methods PUT DELETE MKCOL COPY MOVE;

表明已经配置允许了 ``MKCOL`` WebDAV指令，但是完整的WebDAV指令支持已经不在NGINX中:

这个问题参考:

- `nginx webdav could not open collection <https://stackoverflow.com/questions/24666457/nginx-webdav-could-not-open-collection>`_ : nginx内建的webdav模块已经不在使用，需要使用第三方 `nginx-dav-ext-module <https://github.com/arut/nginx-dav-ext-module>`_
- `Backing up using webDAV from DAVx⁵ to nginx fails with HTTP 409, HTTP 405 #500 <https://github.com/seedvault-app/seedvault/issues/500>`_ : 通过第三方 `nginx-dav-ext-module <https://github.com/arut/nginx-dav-ext-module>`_ 可以解决 ``PROPFIND`` 实现，建议采用 ``external module`` 构建这个模块，这样可以按需启用模块无需重复编译NGINX

编译包含 `nginx-dav-ext-module <https://github.com/arut/nginx-dav-ext-module>`_ 的NGINX
-----------------------------------------------------------------------------------------

.. note::

   标准的 `ngx_http_dav_module <http://nginx.org/en/docs/http/ngx_http_dav_module.html>`_ 只提供部分WebDAV实现，只支持 ``GET,HEAD,PUT,DELETE,MKCOL,COPY,MOVE`` 方法；而 `nginx-dav-ext-module <https://github.com/arut/nginx-dav-ext-module>`_ 扩展支持了完整的WebDAV方法。

待续...

参考
=======

- `How to create a webdav server with Nginx <https://www.filestash.app/2021/12/09/nginx-webdav/>`_
- `Module ngx_http_dav_module <https://nginx.org/en/docs/http/ngx_http_dav_module.html>`_
- `nginx webdav could not open collection <https://stackoverflow.com/questions/24666457/nginx-webdav-could-not-open-collection>`_
