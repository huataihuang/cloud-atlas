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

差异对比
----------

但是我线下测试环境验证是通过的，所以考虑生产和线下环境的差异:

- 线上生产环境采用了 ``2次`` 反向代理，也就是在我的 :ref:`nginx_reverse_proxy` 前面还有一层 NGINX 做反向代理(不是我的管理范围，所以我无法检查具体配置)
- 生产环境的第一层NGINX反向代理启用了 SSL ，也就是第一层反向代理到我的第二层NGINX反向代理，我的第二层NGINX反向代理是没有SSL加密的
- 怀疑第一层反向代理的HTTP头部改写可能触发了Grafana的安全限制

验证思路:

- 将二层反向代理改为 :ref:`iptables_port_forwarding` ，然后直接本地绑定 ``/etc/hosts`` 以域名方式访问，验证是否实现可以域名形式访问Grafana ``NodePort`` 模式(注意，没有配置Grafana的 ``grafana.ini`` 的 ``domain`` )
- 将二层反向代理改为 :ref:`iptables_port_forwarding` ，这样看第一层反向代理是否可以实现域名方式访问 Grafana(其实现在就是 :ref:`iptables_port_forwarding` 访问 ``NodePort`` 模式，只是没有经过第一层反向代理的域名访问方式而是使用IP访问)
- 本地通过 ``/etc/hosts`` 绑定域名解析，绕过第一层NGINX反向代理，直接访问第二层反向代理(第二层由 :ref:`iptables_port_forwarding` 改为 :ref:`nginx_reverse_proxy` )，看能否实现域名方式访问 Grafana (类似我在线下测试环境部署)
- 在二层反向代理配置 ``proxy_hide_header X-Frame-Options;``
- 通过 :ref:`curl_show_request_headers` 对比检查上述访问的差异

验证一
--------------

在物理主机主机上采用 :ref:`iptables_port_forwarding` ，本地绑定 ``/etc/hosts`` 以域名方式访问:

- 验证成功，可以直接使用域名访问 Grafana ``NodePort`` 模式(没有配置Grafana的 ``grafana.ini`` 的 ``domain`` )

验证二
-------------

在物理主机上保持 :ref:`iptables_port_forwarding` ，然后去除本地绑定 ``/etc/hosts`` ，这样客户端访问就会通过域名直接访问第一层反向代理，通过反向代理访问 :ref:`iptables_port_forwarding` 来访问  Grafana ``NodePort`` :

第一层反向代理采用了SSL卸载，也就是强制转跳https，然后反向代理到后端物理主机 :ref:`iptables_port_forwarding` **80** 端口，来访问 Grafana ``NodePort``

果然，出问题在这里，此时再重现了 ``401 Unauthroized`` 报错

- 检查 ``grafana`` 日志::

   kubectl -n prometheus logs kube-prometheus-stack-1681228346-grafana-849b55868d-j62r9 -c grafana --follow

可以看到::

   logger=http.server t=2023-04-22T13:15:36.598575746Z level=info msg="Successful Login" User=admin@localhost
   logger=context userId=1 orgId=1 uname=admin t=2023-04-22T13:15:37.039013543Z level=info msg="Request Completed" method=GET path=/api/live/ws status=-1 remote_addr=192.168.147.143 time_ms=0 duration=739.195µs size=0 referer= handler=/api/live/ws
   logger=context userId=0 orgId=0 uname= t=2023-04-22T13:15:37.084924294Z level=info msg="Request Completed" method=GET path=/api/login/ping status=401 remote_addr=192.168.147.143 time_ms=0 duration=374.008µs size=26 referer=https://grafana.cloud-atlas.io/ handler=/api/login/ping
   logger=context userId=0 orgId=0 uname= t=2023-04-22T13:15:37.182058314Z level=info msg="Request Completed" method=GET path=/ status=302 remote_addr=192.168.147.143 time_ms=0 duration=348.336µs size=29 referer=https://grafana.cloud-atlas.io/ handler=/

注意到 ``grafana`` 记录了 ``admin@localhost`` 登陆成功，但是 https 域名是否会和 Grafana 自身的 **80** 端口不一致而导致异常呢？

果然，在 `Grafana / HTTPS / Nginx Proxy <https://community.grafana.com/t/grafana-https-nginx-proxy/17016>`_ 帖子中提到了修订 ``grafana.ini`` 配置，在 ``grafana`` 端依然是 ``protocol = http`` ，但是要修改 ``root_url = https://my.domain.name/`` 告知域名通过反向代理访问

- 对比 ``ConfigMap`` 配置::

   kubectl -n prometheus edit cm kube-prometheus-stack-1681228346-grafana

可以看到当前默认的 ``grafana`` 的 ``ConfigMap`` 是:

.. literalinclude:: grafana_behind_reverse_proxy/default_grafana_configmap.yaml
   :language: yaml
   :caption: 默认grafana ConfigMap

登陆到容器内部检查::

   kubectl -n prometheus exec -it kube-prometheus-stack-1681228346-grafana-849b55868d-j62r9 -c grafana -- /bin/bash

可以看到 ``/etc/grafana/grafana.ini`` 内容和 ``ConfigMap`` 对应:

.. literalinclude:: grafana_behind_reverse_proxy/default_grafana.ini
   :language: ini
   :caption: 默认grafana.ini配置，和ConfigMap对应 

- 修订 ``ConfigMap`` 配置:

.. literalinclude:: grafana_behind_reverse_proxy/grafana_configmap.yaml
   :language: yaml
   :caption: 修订grafana ConfigMap
   :emphasize-lines: 16-18

.. note::

   如果配置了 ``enforce_domain = true`` ，就会强制使用域名访问，即使你使用了IP地址访问，也会重定向到域名

但是，我发现还是没有解决我的这个生产环境问题，依然报错账号密码错误

- 对比了线上另外一个正常访问的grafana，在容器中 ``/etc/grafana/grafana.ini`` 有一项允许嵌入::

   [security]
   allow_embedding = true

我尝试添加也没有解决登陆(允许嵌入是不是降低了安全要求?)

诡异的是，用户账号密码正确，而且也有一瞬间能够正常登陆，但是立即退出系统

乌龙了
--------

我发现原来是一个业务流程申请错误导致的:

- 我们在两个集群分别部署了 ``kube-prometheus-stack`` ，公司的负载均衡申请流程非常繁杂，完全是一个黑盒: 需要按照应用绑定，我现在回想起来，实际上就是按照 **应用名** 构建了 :ref:`nginx_reverse_proxy` 的 ``upstream`` 配置

  - 但是公司的负载均衡将一个简单的 :ref:`nginx_reverse_proxy` 配置拆解成多个申请流程，没有任何原理说明，导致我将两个集群的 ``kube-prometheus-stack`` 申请为一个应用名，实际上反向带来会将 ``upstream`` 随机发给两个集群中的两套 ``grafana`` ，相互间数据踩踏

我是怎么发现这个问题的呢:

我发现有时候Grafana登陆时显示认证正确，直接登陆进去但是立即被系统推出(实际上是负载均衡恰好将认证发送到符合正确密码的那套 ``grafana`` ，但是认证后后续操作发送给错误的那套 ``grafana`` ，由于session不匹配直接被系统强制登出)，我突然想到会不会搞混了后端 ``grafana`` 系统，所以在登陆的时候同时打开了两个集群的 ``grafana`` pods日志观察，果然发现在登陆瞬间，两个不同集群的 ``grafana`` 都出现访问日志，而且从日志观察，错误接收数据的 ``grafana`` 系统出现了不应该出现的域名记录。

**唉，真是一个惨痛的教训，折腾了好几天...**

参考
======

- `Run Grafana behind a reverse proxy <https://grafana.com/tutorials/run-grafana-behind-a-proxy/>`_
- `Grafana 7.5.15 and 8.3.5 released with moderate severity security fixes <https://grafana.com/blog/2022/02/08/grafana-7.5.15-and-8.3.5-released-with-moderate-severity-security-fixes/>`_
- `New CSRF check broken with raw IPv6 Host #45115 <https://github.com/grafana/grafana/issues/45115>`_
- `Unable to Create/Save Dashboard after v8.3.5 Update #45117 <https://github.com/grafana/grafana/issues/45117>`_
- `Origin not allowed error when reverse proxying grafana #8067 <https://github.com/linkerd/linkerd2/issues/8067>`_
- `Alternative solution for “401: Unauthorized” in Grafana iframe card <https://community.home-assistant.io/t/alternative-solution-for-401-unauthorized-in-grafana-iframe-card/336991>`_ 在iframe card嵌入Grafana时候的解决方法讨论，思路就是不要出现跨站拒绝:

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
