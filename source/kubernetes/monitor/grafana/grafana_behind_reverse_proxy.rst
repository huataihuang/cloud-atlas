.. _grafana_behind_reverse_proxy:

==========================
在反向代理后面运行Grafana
==========================

我在 :ref:`helm3_prometheus_grafana` 为了快速解决服务输出，采用了 ``NodePort`` 模式，此时在节点输出的端口是随机(可以指定，但是范围限定为 ``30000–32767`` )。为了方便用户访问，在主机上配置 :ref:`nginx_reverse_proxy` 以便用户能够以众所周知的固定服务端口访问。

- ``/etc/nginx/sites-enabled`` 目录下软连接 ``/etc/nginx/sites-availabled`` 目录下的3个自定义配置文件::

   alertmanager
   grafana
   prometheus

``alertmanager`` 配置文件内容:

.. literalinclude:: grafana_behind_reverse_proxy/alertmanager
   :caption: NGINX 反向代理 ``alertmanager`` 配置

.. literalinclude:: grafana_behind_reverse_proxy/grafana
   :caption: NGINX 反向代理 ``grafana`` 配置

.. literalinclude:: grafana_behind_reverse_proxy/prometheus
   :caption: NGINX 反向代理 ``prometheus`` 配置

.. note::

   虽然 ``kube-prometheus-stack`` 的 ``values.yaml`` 对于配置域名方式访问 Grafana 需要配置 ``domain`` (见下文)。但是我实践发现，对于 :ref:`nginx_reverse_proxy` ，仅参考 `Run Grafana behind a reverse proxy <https://grafana.com/tutorials/run-grafana-behind-a-proxy/>`_ 完成 :ref:`nginx_reverse_proxy` 配置就可以以域名访问Grafana面板。

**成功**

``9090`` 端口绑定错误
-----------------------

最初我按照 :ref:`prometheus` 默认对外服务端口 ``9090`` 来配置 :ref:`nginx` ，但是启动失败 ``journalctl -xeu nginx.service`` 检查服务器启动日志:

.. literalinclude:: grafana_behind_reverse_proxy/nginx_9090_conflict_cockpit
   :language: bash
   :caption: nginx反向代理prometheus,绑定9090端口失败: 和系统 :ref:`cockpit` 默认端口冲突
   :emphasize-lines: 1

通过 ``lsof | grep 9090`` 可以看到是 :ref:`systemd` 绑定了 ``9090`` 端口::

   systemd       1                            root   56u     IPv6              41495      0t0        TCP *:9090 (LISTEN)

然后通过 ``grep -R 9090 /etc/systemd/*`` 可以看到该端口默认被 :ref:`cockpit` 占用::

   system/sockets.target.wants/cockpit.socket:ListenStream=9090

所以将 :ref:`prometheus` 端口修订为 ``9092``

"401 Unauthorized"报错
======================

生产环境，同样使用 ``kube-prometheus-stack`` 部署Grafana ( 方法同 :ref:`z-k8s_gpu_prometheus_grafana` )，使用IP访问运行正常。但是我切换到 :ref:`nginx_reverse_proxy` 之后，虽然按照 `Run Grafana behind a reverse proxy <https://grafana.com/tutorials/run-grafana-behind-a-proxy/>`_ 配置了NGINX，但是发现域名访问会出现报错 ``401 Unauthorized``

我采用了 :ref:`update_prometheus_config_k8s` : 先修订 ``kube-prometheus-stack.values`` ，修订了 ``domain`` 配置，举例::

    ## Hostnames.
    ## Must be provided if Ingress is enable.
    ##
    # hosts:
    #   - grafana.domain.com
    hosts:
      - grafana.example.com 

但是我发现 Grafana 容器启动后，我检查 ``configMap`` 配置::

   kubectl -n prometheus edit cm kube-prometheus-stack-1681228346-grafana

显示内容:

.. literalinclude:: grafana_behind_reverse_proxy/grafa_cm_no_domain
   :language: yaml
   :caption: 检查 Grafana 的 configMap 发现 ``domain`` 是空的
   :emphasize-lines: 17

并且登陆到容器内部::

   kubectl -n prometheus exec -it  kube-prometheus-stack-1681228346-grafana-fb4695b7-2qhpp -c grafana -- /bin/sh

也可以看到 ``/etc/grafana/grafana.ini`` 完全对应这个配置，也就是 ``domain`` 是空的

我手工修订了 configMap ，然后删除重建pod

现在可以看到容器内部 ``/etc/grafana/grafana.ini`` 页更新了::

   [server]
   domain = 'grafana.example.com'

但是还是没有解决 "401 Unauthorized"报错，而且不仅域名不能访问，IP也不行了(之前也不是可以，只是cookie没有失效无需认证而已；实际重建容器，即使IP也不能登陆了)。

反复尝试，发现:

- 配置了 ``kube-prometheus-stack.values`` 同时手工修改 ``cm kube-prometheus-stack-1681228346-grafana`` 会导致IP和域名访问都失效
- 去除 ``kube-prometheus-stack.values`` 配置(即不使用 ``kube-prometheus-stack`` 域名配置)，但是手工修改 ``cm kube-prometheus-stack-1681228346-grafana`` ，此时容器内部 ``/etc/grafana/grafana.ini`` 会注入 ``domain = 'grafana.example.com'`` ，但是域名访问不行，不过IP访问却是正常。目前先用IP访问，待查

但是我线下测试环境验证是通过的，所以考虑生产和线下环境的差异:

- 线上生产环境采用了 ``2次`` 反向代理，也就是在我的 :ref:`nginx_reverse_proxy` 前面还有一层 NGINX 做反向代理(不是我的管理范围，所以我无法检查具体配置)
- 生产环境的第一层NGINX反向代理启用了 SSL ，也就是第一层反向代理到我的第二层NGINX反向代理，我的第二层NGINX反向代理是没有SSL加密的
- 怀疑第一层反向代理的HTTP头部改写可能触发了Grafana的安全限制

我准备再尝试修订NGINX的http头部改写配置，见参考部分

参考
======

- `Run Grafana behind a reverse proxy <https://grafana.com/tutorials/run-grafana-behind-a-proxy/>`_
- `Grafana 7.5.15 and 8.3.5 released with moderate severity security fixes <https://grafana.com/blog/2022/02/08/grafana-7.5.15-and-8.3.5-released-with-moderate-severity-security-fixes/>`_
- `New CSRF check broken with raw IPv6 Host #45115 <https://github.com/grafana/grafana/issues/45115>`_
- `Unable to Create/Save Dashboard after v8.3.5 Update #45117 <https://github.com/grafana/grafana/issues/45117>`_
- `Origin not allowed error when reverse proxying grafana #8067 <https://github.com/linkerd/linkerd2/issues/8067>`_
- `Alternative solution for “401: Unauthorized” in Grafana iframe card <https://community.home-assistant.io/t/alternative-solution-for-401-unauthorized-in-grafana-iframe-card/336991>`_ 在iframe card嵌入Grafana时候的解决方法讨论，思路就是不要出现跨站拒绝，主要思路:

   - ``GF_AUTH_ANONYMOUS_ENABLED`` 或者 ``GF_SECURITY_ALLOW_EMBEDDING`` 设置到Grafana配置中::

      - name: GF_AUTH_ANONYMOUS_ENABLED
        value: "true"
      - name: GF_DASHBOARDS_MIN_REFRESH_INTERVAL
        value: 30s
      - name: GF_DATE_FORMATS_INTERVAL_HOUR
        value: DD/MM HH:mm
      - name: GF_DATE_FORMATS_INTERVAL_DAY
        value: DD/MM
 
   - 在NGINX反向代理中加上 ``proxy_hide_header X-Frame-Options;`` 丢弃掉

- `unauthorized errors when using reverse proxy with sub-path method #11757 <https://github.com/grafana/grafana/issues/11757>`_ 有一些讨论
