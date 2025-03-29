.. _curl_https:

==========================
Curl访问https
==========================

自签名HTTPS服务器访问
=========================

- 参数 ``-k`` 可以忽略服务器证书错误::

   -k, --insecure           Allow insecure server connections

对于自签名的HTTPS服务器，可以采用这个方式访问::

   curl -k https://myserver

但是不推荐忽略服务器证书错误，这样容易出现中间人攻击。建议下载服务器证书，然后以确认的服务器证书来访问服务器:

.. literalinclude:: curl_https/openssl_get_https_server_certificate
   :language: bash
   :caption: 使用openssl获取https服务器的证书

上述命令会长时间连接服务器直到超时断开，我们会在终端完整看到服务器证书链

- 将上述命令修改成截取服务器证书文件保存到本地:

.. literalinclude:: curl_https/openssl_get_https_server_certificate_pem
   :language: bash
   :caption: 使用openssl获取https服务器的证书pem并保存

- 使用服务器证书访问https:

.. literalinclude:: curl_https/curl_cacert_pem
   :language: bash
   :caption: curl使用下载的服务器证书访问HTTPS

.. note::

   这个使用服务器证书的方法还有一些疑问，我实际使用时依然出现证书问题(服务器的证书签名和域名不一致，还是无法使用)，目前还是用 ``-k`` 参数绕过问题

参考
======

- `HTTPS Connection Using Curl <https://www.baeldung.com/linux/curl-https-connection>`_
