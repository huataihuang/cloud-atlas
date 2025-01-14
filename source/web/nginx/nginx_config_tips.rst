.. _nginx_config_tips:

=====================
NGINX配置Tips
=====================

反向代理(upstream servers)激活keepalive
=========================================

默认情况下，NGINX会为 ``每个新进入请求`` 向upstream(backend)服务器发起一次新连接。这个特性时安全的，但是也是非常低效的，因为每建立一次连接NGINX和后端服务器之间必须交换三次数据包，而且断开连接也需要三到四个数据包。

对于高流量情况下，为每个请求打开一个新连接会很快耗尽系统资源，甚至导致无法打开连接。原因是：对于每个连接，原地址、源端口、目标地址和目标端口 ``四元组`` 必须唯一。对于从NGINX到上游服务器连接，其中三个元素时固定的，只有 ``源端口`` 作为变量。当连接关闭时，Linux套接字会处于 ``TIME-WAIT`` 状态 **两分钟** ，这在搞流量情况下增加了耗尽可用源端口池的可能性。如果发生这种情况，NGINX就无法打开到上游服务器的新连接。

解决方法时启用NGINX和upstream server之间 ``keepalive`` : 请求完成后，连接不关闭，而是保持打开状态以用于其他请求。这既降低了源端口耗尽的可能性，又提高了性能。

- 在每个 ``upstream{}`` 块中包含 ``keepalive`` 指令，以设置每个工作进程缓存中保存的与upstream server的空闲keepalive连接数
- ``keepalive`` 指令不会限制NGINX工作进程可以打开的与upstream server的连接总数，所以， ``keepalive`` 不需要设置得非常大
- 建议将参数设置为 ``upstream{}`` 块中列出服务器数量的 **两倍** ，这足以让NGINX与所有服务器保持 ``keepalive`` 连接，有足够小，以便upstream sever也可以处理新的传入连接
- **注意** 在 ``upstream{}`` 块中指定负载均衡算法时(使用 ``hash`` / ``ip_hash`` / ``last_conn`` / ``least_time`` / ``random`` 指令)，则这些负载均衡算法指令 **必须** 出现在 ``keepalive`` 指令上方。这是NGINX配置中指令顺序无关紧要的一般规则中罕见例外之一。
- 在将请求转发到 upstream server 组的 ``location{}`` 块中，将以下指令与 ``proxy_pass`` 指令一起包含

.. literalinclude:: nginx_config_tips/proxy.conf
   :caption: 配置keepalive

我在配置 :ref:`nginx_reverse_proxy_https` 使用了这个配置( 详见 :ref:`nginx_config_include` ):

.. literalinclude:: nginx_config_include/proxy_set.conf
   :caption: ``/etc/nginx/include/proxy/proxy_set.conf``
   :emphasize-lines: 1,9

注意，这里一定要设置 ``HTTP/1.1`` ，因为当默认使用 ``HTTP/1.0`` 连接upstream server时，会将 ``Connection: close`` header添加到转发服务器请求中，这就会导致 ``upstream{}`` 块中的 ``keepalive`` 指令不生效，每个连接都会在请求完成时关闭:

- ``proxy_http_version`` 指令告诉NGINX使用 ``HTTP/1.1``
- ``proxy_set_header`` 从 ``Connection`` header中删除 ``close`` 值

参考
=======

- `Avoiding the Top 10 NGINX Configuration Mistakes <https://www.f5.com/company/blog/nginx/avoiding-top-10-nginx-configuration-mistakes>`_
