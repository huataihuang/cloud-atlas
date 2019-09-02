.. _remote-access-dockerd:

======================
远程访问dockerd服务
======================

虽然默认情况下都是在host主机上访问Docker daemon，不过，远程访问Docker daemon也很有必要，特别是在DevOps工作流中，往往需要远程调试Docker。

.. warning::

   虽然远程访问Docker daemon是非常强大的技术，但是需要考虑安全性。Docker socket可能被滥用并导致攻击。

.. image:: ../../_static/docker/docker_daemon_remote_access.png
   :scale: 50

docker的TCP访问
----------------------

默认Docker配置限制只能通过 ``/var/run/docker.sock`` 在本地host上访问Docker daemon，这样非host主机上的进程就不能访问Docker服务，这提供了一定的安全保障。

通过Docker配置修改，可以将Docker daemon的访问通过TCP网络输出给外部访问，这样不仅远程Docker client可以管理Docker，并且可以集成到Jenkins这样的持续集成系统，实现软件开发部署的持续交付流程。

* 修改配置之前，首先停止Docker daemon::

   sudo systemctl stop docker

* 开启Docker daemon的TCP访问

可以通过手工命令运行Docker daemon提供对外的TCP访问::

   sudo docker daemon -H tcp://0.0.0.0:2375

或者通过环境变量 ``DOCKER_HOST`` 来使得docker运行时启用TCP::

   export DOCKER_HOST=tcp://<your host's ip>:2375
   docker <subcommand>

Ubuntu早期版本
--------------------

Ubuntu 上默认启动的docker服务显示的运行参数是 ``/usr/bin/dockerd -H fd://`` 。参考 `Enabling and accessing Docker Engine API on a remote docker host on Ubuntu <https://medium.com/@sudarakayasindu/enabling-and-accessing-docker-engine-api-on-a-remote-docker-host-on-ubuntu-16-04-2c15f55f5d39>`_

早期Ubuntu版本采用修改 ``/etc/defualt/docker`` 配置文件，添加::

   DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock"

使用systemd的现代Ubuntu版本
-----------------------------

在当前采用systemd的系统中，激活remote API的方法参考 `How do I enable the remote API for dockerd <https://success.docker.com/article/how-do-i-enable-the-remote-api-for-dockerd>`_  ，创建一个 ``/etc/systemd/system/docker.service.d/startup_options.conf`` ::

   # /etc/systemd/system/docker.service.d/override.conf
   [Service]
   ExecStart=
   ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375

.. note::

   ``-H`` 参数可以指定dockerd的监听socket，可以是Unix socket或者TCP端口。可以指定多个 ``-H`` 参数来绑定多个 sockets/ports。默认的 ``-H fd://`` 使用的是systemd的socket激活功能，引用的是 ``/lib/systemd/system/docker.service`` 。

   从上述配置 ``startup_options.conf`` 来看，是先将 ``ExecStart`` 配置清空然后再重新加入完整新配置。

然后重新加载unit文件::

   sudo systemctl daemon-reload

使用新的参数重启::

   sudo systemctl restart docker.service

.. note::

   如果没有使用上述这种override方式，也可以直接修改 ``/lib/systemd/system/docker.service`` 配置文件，同样可以添加监听参数。但是这种直接修改系统配置文件的方法会对后续升级影响。

   ``/lib/systemd/system/docker.service`` 配置中如果有 ``EnvironmentFile=`` 配置项，则指定环境参数文件，就可以通过环境参数文件内容来添加参数。

* 检查docker重启后日志::

   journalctl -u docker
   journalctl -u docker -f

可以看到日志显示TCP端口监听::

   Feb 20 08:32:01 kube systemd[1]: Started Docker Application Container Engine.
   Feb 20 08:32:01 kube dockerd[2010]: time="2019-02-20T08:32:01.987747054+08:00" level=info msg="API listen on [::]:2375"
   Feb 20 08:32:01 kube dockerd[2010]: time="2019-02-20T08:32:01.988023375+08:00" level=info msg="API listen on /var/run/docker.sock"

docker客户端远程连接测试
------------------------------

现在可以在远程主机上使用如下命令语法来测试::

   docker -H tcp://<your host's ip>:2375 <subcommand>

举例，显示远程服务器上的镜像列表::

   docker -H tcp://192.168.64.3:2375 images

为了方便远程调试，也可以先创建 ``DOCKER_HOST`` 环境变量（这种方式在 ``sudo`` 方式执行docker不生效）::

   export DOCKER_HOST=tcp://<your host's ip>:2375
   docker <subcommand>

.. warning::

   如果直接使用 ``0.0.0.0`` 作为绑定docker daemon的地址会存在安全隐患，所以这种远程访问配置仅适合在公司局域网内部使用。并且最好是有专用的私有管控网络接口，然后指定docker daemon只在指定的网络接口上打开TCP端口服务，这样可以提高安全性。
