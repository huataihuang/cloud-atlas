.. _curl_proxy:

=================
curl代理
=================

命令行
=======

http/https代理
-------------------

- 命令行 ``curl`` 可以直接使用代理::

   curl https://reqbin.com/echo -x myproxy.com:8080 -U login:password

举例，我在 :ref:`nodejs_dev_env` 需要安装 ``nvm`` ，但是 raw.githubusercontent.com 被墙，所以需要通过以下命令通过代理访问::

   curl -x 192.168.10.9:3128 -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

socks5代理
------------

- 命令行 ``curl`` 可以使用 ``socks5h`` 方式::

   curl -x socks5h://localhost:1080 -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

持久化配置
==========

http/https代理
---------------------

- 环境设置，注意配置去除本地回环地址过滤，避免一些特殊的访问失败( :ref:`homebrew` 安装openssl组件测试回环地址端口会失败)

.. literalinclude:: curl_proxy/http_env
   :caption: 配置curl的http/https代理环境变量


- 环境变量设置:

.. literalinclude:: curl_proxy/socks5_http_env
   :caption: 配置curl的http/https代理环境变量

- 或者采用 ``~/.curlrc`` :

.. literalinclude:: curl_proxy/curlrc
   :caption: 配置 ``~/.curlrc`` 设置http/https代理

socks5代理
------------

比较特别，对于socks代理，变量是使用全部大写字母:

.. literalinclude:: curl_proxy/socks5_proxy_env
   :caption: 配置curl的socks5代理环境变量

参考
=======

- `How do I use Curl with a proxy? <https://reqbin.com/req/c-ddxflki5/curl-proxy-server>`_
- `performing HTTP requests with cURL (using PROXY) <https://stackoverflow.com/questions/9445489/performing-http-requests-with-curl-using-proxy>`_
- `How to use curl command with proxy username/password on Linux/ Unix <https://www.cyberciti.biz/faq/linux-unix-curl-command-with-proxy-username-password-http-options/>`_
- `How to Use Socks5 Proxy in Curl <https://blog.emacsos.com/use-socks5-proxy-in-curl.html>`_
- `Proxy exceptions when using $http_proxy env var? [closed] <https://serverfault.com/questions/42426/proxy-exceptions-when-using-http-proxy-env-var>`_
