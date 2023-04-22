.. _ grafana_reset_admin_password:

================================
重置Grafana管理员密码
================================

配置过程中调整过几次密码，有点搞混忘记了Grafana的admin密码，所以我决定重置admin密码。部署环境采用的是 :ref:`z-k8s_gpu_prometheus_grafana` 方法

- 登陆到 ``grafana`` pods::

   kubectl -n prometheus exec -it kube-prometheus-stack-1681228346-grafana-849b55868d-j62r9 -c grafana -- /bin/bash

重置密码命令需要传递 ``grafana`` 的 ``homepath`` 参数，所以先检查当前运行的路径 ``ps aux | grep grafana`` ::

   1 grafana   6:24 grafana server --homepath=/usr/share/grafana --config=/etc/grafana/grafana.ini --packaging=docker cfg:default.log.mode=console cfg:default.paths.data=/var/lib/grafana/ cfg:default.paths.logs=/var/log/grafana cfg:default.paths.plugins=/var/lib/grafana/plugins cfg:default.paths.provisioning=/etc/grafana/provisioning

可以看到 ``homepath`` 是 ``/usr/share/grafana`` ，执行以下重置命令::

   grafana-cli --homepath "/usr/share/grafana" admin reset-admin-password <new password>

参考
=====

- `Grafana Admin password reset <https://community.grafana.com/t/admin-password-reset/19455>`_
