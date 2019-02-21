.. _running-containers-as-daemons:

======================
将容器作为服务运行
======================

在之前的命令行运行docker，默认是在前台运行。不过，实际上Docker作为容器运行，通常是作为服务在后台运行。

参数 ``-d`` 提供了 ``docker run`` 命令后台运行的能力，并且可以使用容器管理相关的开关参数。

使用 ``-d`` 参数运行容器::

   docker run -d -i -p 1234:1234 --name daemon ubuntu:14.04 nc -l 1234

**参数说明**

-d    结合 ``docker run`` 使用，表示容器作为daemon运行
-i    交互模式，可以通过telnet会话和容器交互
-p    从容器发布1234端口到host主机
--name  容器命名为 ``daemon``

**最后的两个参数**

* ``ubuntu:14.04`` 使用用的镜像名称
* ``nc -l 1234`` 表示最后运行在容器内部的命令，这里是提供了一个 ``nc`` 监听在端口 ``1234`` 可以实现echo调试。

上述docker容器运行在后台，通过 ``docker ps`` 命令可以看到运行中的容器::

   CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                    NAMES
   25ca718c317b        ubuntu:14.04        "nc -l 1234"        18 seconds ago      Up 16 seconds       0.0.0.0:1234->1234/tcp   daemon

现在我们可以通过 ``telnet`` 命令来验证(192.168.64.3是运行docker的host主机IP)::

   telnet 192.168.64.3 1234

交互过程如下::

   $ telnet 192.168.64.3 1234
   Trying 192.168.64.3...
   Connected to 192.168.64.3.
   Escape character is '^]'.
   helo daemon  <--这里输入字符串
   ^]  <--这里按下ctrl-[表示退出telnet会话
   telnet> q  <-这里按下q退出telnet程序
   Connection closed.

.. note::

   上述telnet交互会话退出以后，服务端的 ``nc -l 1234`` 也会结束，所以，此时再次使用 ``docker ps`` 检查可以看到容器 ``daemon`` 已经中止了。

   容器的日志会记录 ``nc -l 1234`` 命令的输出，所以使用以下命令可以查看容器输出::

      docker logs daemon

   得到的日志内容如下::

      hello daemon

自动重启容器策略
=====================

``docker run`` 有一个 ``--restart`` 参数，可以设置容器中止时候的策略

======================  ==============================
策略                    描述
======================  ==============================
no                      容器退出时不重启
always                  容器退出时总是重启
unless-stopped          总是重启，但是记住明确的停止
on-failure[:max-retry]  只有故障时重启
======================  ==============================

最简单的是 ``no`` 策略：当容器退出是，并不会重启。这也是默认策略。

``always`` 策略也简单，就是直接重启::

   docker run -d --restart=always ubuntu:14.04 echo done

此时通过 ``docker ps`` 检查可以看到容器在不断重启::

   $ docker ps
   CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                         PORTS               NAMES
   3ffaf6484a53        ubuntu:14.04        "echo done"         37 seconds ago      Restarting (0) 8 seconds ago                       vigorous_bhaskara

.. note::

   在上述 ``docker ps`` 检查中可以看到 ``STATUS`` 状态返回的值是 ``0`` ，这表明运行成功。并且，每次容器重启，容器的名字不会变化。

``unless-stopped`` 和 ``always`` 策略差不多，但是会记住daemon重启过（例如你重启了主机），这种情况下就不会自动重启容器。与此相反， ``always`` 策略会会在主机重启之后，自动把容器拉起。这对于一些服务来说可能是必要的策略。

``on-failure`` 策略则是特别的，只在容器返回了一个非0的值（通常意味着失败）才会重启容器::

   docker run -d --restart=on-failure:10 ubuntu:14.04 /bin/false

.. note::

   将服务放到后台运行时，通常不能很直观发现服务是否crash，这给运维工作带来了要求。通常需要配合服务监控、日志输出及分析来确保服务可控运维。
