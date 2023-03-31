.. _grafana_behind_reverse_proxy:

==========================
在反向代理后面运行Grafana
==========================

我在 :ref:`helm3_prometheus_grafana` 为了快速解决服务输出，采用了 ``NodePort`` 模式，此时在节点输出的端口是随机(可以指定，但是范围限定为 ``30000–32767`` )。为了方便用户访问，在主机上配置 :ref:`nginx_reserve_proxy` 以便用户能够以众所周知的固定服务端口访问。

但是，却发现: 虽然能够正常访问 Grafana 面板(能够通过默认账号密码登陆)，但是却无法做任何修改，例如密码修改。此时页面右上角会提示错误 ``origin not allowed`` ，实际上任何配置修改都无法完成

原因分析
=========



参考
======

- `Run Grafana behind a reverse proxy <https://grafana.com/tutorials/run-grafana-behind-a-proxy/>`_
- `Grafana 7.5.15 and 8.3.5 released with moderate severity security fixes <https://grafana.com/blog/2022/02/08/grafana-7.5.15-and-8.3.5-released-with-moderate-severity-security-fixes/>`_
- `New CSRF check broken with raw IPv6 Host #45115 <https://github.com/grafana/grafana/issues/45115>`_
- `Unable to Create/Save Dashboard after v8.3.5 Update #45117 <https://github.com/grafana/grafana/issues/45117>`_
- `Origin not allowed error when reverse proxying grafana #8067 <https://github.com/linkerd/linkerd2/issues/8067>`_
