.. _start_containers_automatically:

=========================
自动启动Docker容器
=========================

在 :ref:`ceph_docker_in_studio` 时，Ceph是作为整个OpenStack集群的基础服务来运行的，所以需要设置操作系统启动时自动启动这些Ceph容器，以便能够为上层OpenStack提供基础。在生产环境中，如果是通过Docker容器来运行基础服务，往往也需要能够自动启动这些Docker容器。

.. note::

   使用Kubernetes ( :ref:`kubernetes` ) 的调度可以自动实现稳定的容器服务，但是在 :ref:`introduce_my_studio` ，直接采用Docker `restart policies <https://docs.docker.com/v17.09/engine/reference/run/#restart-policies---restart>`_ 可以无需复杂的部署（消耗大量主机资源）实现底层分布式存储服务持续运行。

Docker重启策略
===============

Docker 提供了 ``restart policies`` 来控制容器退出或者Docker重启时候是否自动启动容器。重启策略确保了链接的容器按照正确顺序启动。Docker建议使用restart策略而不是使用进程管理器（例如systemd）来启动容器。

.. note::

   Docker的重启策略和 ``dockerd`` 的 ``--live-restore`` 开关是不同的。 ``--live-restore`` 开关允许在Docker升级的时候保持容器继续运行，虽然升级过程中容器的网络和用户输入是中断的。请参考 :ref:`keep_containers_alive_during_daemon_downtime`

使用重启策略
--------------

在执行 ``docker run`` 指令时，可以使用 ``--restart`` 参数来配置容器的重启策略，可用值：

=============== ===========================================================
参数值          描述
=============== ===========================================================
no              不自动重启容器（默认值）
on-failure      当容器发生错误退出（表现为非零的退出值）就重启容器
unless-stopped  除非容器明确停止或者Docker自身停止或重启，否则自动重启容器
always          总是在容器停止时候重启容器
=============== ===========================================================

举例，以下命令总是重启Redis容器，除非容器是明确停止或者Docker被重启::

   docker run -dit --restart unless-stopped redis

重启策略要点
--------------

在使用重启策略时要牢记以下要点：

- 重启策略只有在容器成功启动之后才会生效。这种情况下，所谓成功启动是指容器启动至少10秒钟并且Docker已经开始监控容器。这种模式避免容器没有成功启动而不断循环重启的问题。
- 如果你手工停止一个容器，则该容器的重启策略会被忽略直到Docker服务被重启或者容器被手工重启。这也是避免循环重启的策略。
- 重启策略只作用于容器。通过swarm服务实现的重启策略配置方法不同。

使用进程管理器自动重启容器
============================

如果容器的内建重启策略不能满足需求，例如Docker之外的进程依赖Docker容器，你可以使用进程管理器例如 `upstart <http://upstart.ubuntu.com/>`_ ， `systemd <http://freedesktop.org/wiki/Software/systemd/>`_ 或者 `supervisor <http://supervisord.org/>`_ 来管理容器重启。

.. warning::

   不要试图同时使用Docker内建的重启策略和host级别的进程管理器，这会导致两者冲突。

使用systemd自动启动容器
--------------------------

通过SystemD可以启动和停止服务，也可以跟踪依赖以及检查日志，对于docker，主要是wrap命令并正确命名。

- 通过systemd启动redis服务(参考 `Using Docker containers as Systemd services <https://karlstoney.com/2017/03/03/docker-containers-as-systemd-services/>`_ )::

   [Unit]
   Description=Redis Key Value store
   Requires=docker.service
   
   [Service]
   ExecStartPre=/bin/sleep 1
   ExecStartPre=/bin/docker pull redis:latest
   ExecStart=/bin/docker run --restart=always --name=systemd_redis -p=6379:6379 redis:latest
   ExecStop=/bin/docker stop systemd_redis
   ExecStopPost=/bin/docker rm -f systemd_redis
   ExecReload=/bin/docker restart systemd_redis
   
   [Install]
   WantedBy=multi-user.target

将上述文件保存为 ``/etc/systemd/system/redis-in-docker.service`` 然后执行 ``systemctl daemon-reload`` 。

完成后就可以执行以下命令启动redis服务::

   sudo systemctl start redis-in-docker

启动正常后，就可以设置操作系统启动时启动::

   sudo systemctl enable redis-in-docker

`Running Docker containers with systemd <https://fardog.io/blog/2017/12/30/running-docker-containers-with-systemd/>`_ 提供了一个很好的启动nginx容器的案例可以参考::

   [Unit]
   Description=nginx (Docker)
   # start this unit only after docker has started
   After=docker.service
   Requires=docker.service
    
   [Service]
   TimeoutStartSec=0
   Restart=always
   # The following lines start with '-' because they are allowed to fail without
   # causing startup to fail.
   #
   # Kill the old instance, if it's still running for some reason
   ExecStartPre=-/usr/bin/docker kill nginx
   # Remove the old instance, if it stuck around
   ExecStartPre=-/usr/bin/docker rm nginx
   # Pull the latest version of the container; NOTE you should be careful to
   # pull a tagged version, that way you won't accidentially pull a major-version
   # upgrade and break your service!
   ExecStartPre=-/usr/bin/docker pull "nginx:1.13"
   # Start the actual service; note we remove the instance after it exits
   ExecStart=/usr/bin/docker run --rm --name nginx -p 80:80 -p 443:443 -v /etc/service-configs/nginx/nginx.conf:/etc/nginx/nginx.conf:ro -v /var/www/letsencrypt:/var/www/letsencrypt:z -v /etc/letsencrypt:/etc/letsencrypt:ro nginx:1.13
   # On exit, stop the container
   ExecStop=/usr/bin/docker stop nginx
    
   [Install]
   WantedBy=multi-user.target

在容器内部使用进程管理器
===========================

可以在容器内部运行进程管理器来检查一个进程是否运行或者进程没有运行时启动或重启进程。

.. warning::

   在容器内部使用进程管理器不是Docker可以感知的，并且仅仅在容器内部管理操作系统进程。这种方式不是Docker推荐的方法，因为这种方式和操作系统紧密相关，甚至在Linux发行版的不同版本也有差异。

参考
======

- `Start containers automatically <https://docs.docker.com/config/containers/start-containers-automatically/>`_
- `Using Docker containers as Systemd services <https://karlstoney.com/2017/03/03/docker-containers-as-systemd-services/>`_
- `Running Docker containers with systemd  <https://fardog.io/blog/2017/12/30/running-docker-containers-with-systemd/>`_
