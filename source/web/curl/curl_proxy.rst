.. _curl_proxy:

=================
curl代理
=================

- 命令行 ``curl`` 可以直接使用代理::

   curl https://reqbin.com/echo -x myproxy.com:8080 -U login:password

举例，我在 :ref:`nodejs_dev_env` 需要安装 ``nvm`` ，但是 raw.githubusercontent.com 被墙，所以需要通过以下命令通过代理访问::

   curl -x 192.168.10.106:3128 -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

参考
=======

- `How do I use Curl with a proxy? <https://reqbin.com/req/c-ddxflki5/curl-proxy-server>`_
- `performing HTTP requests with cURL (using PROXY) <https://stackoverflow.com/questions/9445489/performing-http-requests-with-curl-using-proxy>`_
