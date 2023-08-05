.. _prometheus_behind_reverse_proxy:

===============================
在反向代理后面运行Prometheus
===============================

.. _prometheus_sub-path_behind_reverse_proxy:

在反向代理后面采用 ``sub-path`` 的Prometheus
===============================================

在 :ref:`prometheus_startup_centos7` 采用 :ref:`nginx_reverse_proxy` ，使用的是 ``sub-path`` 模式，也就是说我的访问域名 ``onesre.cloud-atlas.io`` 的子路径 ``http://onesre.cloud-atlas.io/prometheus/`` 反向代理到运行 :ref:`prometheus_startup` 部署的服务器:

- 配置 ``/etc/nginx/conf.d/onesre-core.conf`` 设置反向代理:

.. literalinclude:: prometheus_behind_reverse_proxy/sub-path_nginx.conf
   :caption: nginx反向代理，prometheus使用sub-path模式 ``/etc/nginx/conf.d/onesre-core.conf``

- 此时访问页面会报错的，需要修订 ``/etc/systemd/system/prometheus.service`` 添加 ``--web.external-url`` 运行参数:

.. literalinclude:: prometheus_behind_reverse_proxy/prometheus.service
   :caption: 添加 ``--web.external-url`` 运行参数 的 ``/etc/systemd/system/prometheus.service``
   :emphasize-lines: 21

重启 ``prometheus.service`` 之后，就能正常通过 ``http://onesre.cloud-atlas.io/prometheus/`` 反向代理访问新部署的 :ref:`prometheus_startup_centos7`

参考
======

- `Configure Prometheus on a Sub-Path behind Reverse Proxy <https://blog.cubieserver.de/2020/configure-prometheus-on-a-sub-path-behind-reverse-proxy/>`_
