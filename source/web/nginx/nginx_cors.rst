.. _nginx_cors:

=============================
Nginx处理CORS(跨站资源共享)
=============================

我在部署 :ref:`nginx_reverse_proxy_https` 启用了 `docs.cloud-atlas.io 构建 "云图 -- 云计算图志: 探索" <https://docs.cloud-atlas.io/discovery>`_ 自建网站。但是发现一个问题，原本 `utterances <https://utteranc.es/>`_ 构建的 :ref:`sphinx_comments` 无法展示了。

这个问题是我刚切换到 :ref:`freebsd_xfce4` 作为工作平台时发现的，使用浏览器 :ref:`firefox` 存在这个现象，而之前在 :ref:`macos` 平台使用Safari就没有这个问题。看来Firefox有什么特别之处，所以开启 Firefox  的developer tools 观察页面加载情况，就发现原来  https://uteranc.es/client.js 无法加载，提示 `CORS error <https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS/Errors>`_ 。

简单来说，处于网站安全，一个HTTPS加密网站的所有页面应该是(最好)从同一个域名提供，也就是客户端浏览器仅信任自己访问的网站。但是，如果页面中嵌入了其他网站资源，那么从安全严格来讲，客户端有一定理由怀疑存在安全隐患。所以，如果浏览器设置较高安全等级，是会拒绝这种跨域内容的。

解决的方法也比较简单，就是在NGINX发送给客户端ORIGN请求的响应内容的头部插入 ``Access-Control-Allow-Origin`` 字段，表示网站信任和接受那哪些网站提供的资源。o

对于我这里的实践 :ref:`nginx_reverse_proxy_https` ，实际上只要在后端NGINX(也就是反响代理所指向的真正提供内容的后端NGINX服务器上)配置:

.. literalinclude:: nginx_cors/cloud-atlas.io.conf
   :caption: NGINX添加允许 https://utteranc.es ``CORS``
   :emphasize-lines: 15

全面放开nginx的CORS配置
==========================

- 使用以下nginx配置可以放开CORS:

.. literalinclude:: nginx_cors/open.conf
   :caption: Nginx 放开 CORS

参考
=======

- `wikipedia: Cross-origin resource sharing <https://en.wikipedia.org/wiki/Cross-origin_resource_sharing>`_
- `How to enable CORS in Nginx proxy server? <https://stackoverflow.com/questions/45986631/how-to-enable-cors-in-nginx-proxy-server>`_
- `Wide open nginx CORS configuration <https://michielkalkman.com/snippets/nginx-cors-open-configuration/>`_
