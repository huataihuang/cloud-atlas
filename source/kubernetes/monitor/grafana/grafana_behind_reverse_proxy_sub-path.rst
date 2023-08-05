.. _grafana_behind_reverse_proxy_sub-path:

=======================================
在反向代理后面运行Grafana (sub-path)
=======================================

在配合 :ref:`prometheus_startup_centos7` ，也采用了相似的 ``sub-path`` 反向代理：

- 在 :ref:`install_grafana` 完成后，对于反向代理，需要修订 ``/etc/grafana/grafana.ini`` 配置文件:

  - 访问域名 ``domain``
  - 访问url ``root_url``

配置修订位于 ``[server]`` 部分如下:

.. literalinclude:: grafana_behind_reverse_proxy_sub-path/grafana.ini
   :caption: 修订 ``/etc/grafana/grafana.ini`` 配置访问域名以及访问路径


- 在NGINX服务器上 配置 ``/etc/nginx/conf.d/onesre-core.conf`` 设置反向代理:

.. literalinclude:: grafana_behind_reverse_proxy_sub-path/sub-path_nginx.conf
   :caption: nginx反向代理，grafana用sub-path模式 ``/etc/nginx/conf.d/onesre-core.conf``
