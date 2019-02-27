.. _building-a-docker-application:

==========================
构建Docker应用程序
==========================

.. note::

   案例采用「Docker in Practice」介绍的一个to-do应用程序案例。这个to-do应用是一个简单的WEB界面程序，适合作为演示。

.. image:: ../_static/docker/building-a-docker-application.png
   :scale: 50

创建Docker image
==================

有4种创建Docker image的标准方法：

* 使用Docker命令执行 ``docker run`` 并在命令行传递参数，然后通过 ``docker commit`` 将镜像保存
* 使用Dockerfile来从一个现有的基础镜像构建新的镜像。这个方法比较常用
* 使用Dockerfile结合配置管理工具（configuration management tool, CM tool）：类似上一个方法，但是提供了跟多控制能力
* 从头开始的空镜像，通过TAR文件导入系统来构建一个镜像：这是最原始和最初（第一次）构建镜像的方法

Dockerfile文件
----------------

Docker文件实际上就是 Docker 系列命令的集合，一个配置脚本。

todoapp Dockerfile::

   FROM node
    LABEL maintainer ian.miell@gmail.com
    RUN git clone -q https://github.com/docker-in-practice/todo.git
    WORKDIR todo
    RUN npm install > /dev/null
    EXPOSE 8000
    CMD ["npm", "start"]

* ``FROM`` 命令是定义基础镜像命令，这里的指令 ``FROM node`` 指定采用 ``Node.js`` 镜像作为基础，也就是采用官方的 ``Node.js`` 镜像作为基础镜像。（Nodejs的官方镜像名字就是 ``node``  ）

* ``LABEL`` 定义维护者信息，请将这里的定义设置成你自己的。这个定义行在制作一个工作的Docker image不是必须的，但是建议使用。

* 此时镜像已经继承了 ``node`` 容器的状态，所有工作就在这个继承的镜像之上展开。

* ``RUN`` 命令指定在容器内部运行的命令，也就是当容器启动之后，系统自动在容器内部执行的一系列命令。这种方式非常适合定制容器，为容器添加必要的软件包、应用程序等。这里可以看到采用 ``git clone`` 命令实现了将应用软件部署到容器内部的操作。

.. note::

   这里采用 ``node`` 镜像内部默认内置的 ``git`` 来部署应用软件，但是需要注意，并不是所有的基础镜像内部都具有相同的工具和程序。所以，在生产环境中，你应该自己打造基础镜像，确保基础镜像中包含了必要的可以运行的工具命令，以便进一步运行脚本来定制容器。

   此外，实际生产环境部署Docker，最大的困难是保证资源和网络，如果没有合适的基础设施确保Docker能够访问镜像仓库，git仓库或者软件包仓库，定制镜像的Dockerfile运行可能会失败。

* ``WORKDIR todo`` 指令使得容器内部目录更换到上一条 ``RUN git clone ...`` 下载的应用程序目录 ``todo`` 下。注意，这条指令会一直生效，直到遇到下一条 ``WORKDIR`` 指令修改工作目录。所以这个Dockerfile中所有容器内部工作指令都是在 ``todo`` 子目录下执行的。

* ``RUN npm install`` 指令运行的是nodejs应用的依赖安装指令，会构建 ``todo`` 程序运行的nodejs运行环境。这里的重定向 ``> /dev/null`` 使得执行命令的终端输出内容不会干扰Dockerfile执行输出信息。

* 由于nodejs运行程序使用的端口是 ``8000`` ，这个端口是在容器内部的，需要通过 ``EXPOSE`` 指令映射到Docker容器外部，这样外部用户才能访问到容器内部提供的服务。

* 最后一条 ``CMD`` 指令则是Docker容器最后启动执行的指令，也就是运行服务。

.. note::

   通常情况下，对于Docker容器这样的微服务架构，每个容器最后只运行一条 ``CMD`` 指令来运行服务，绝没有多余的服务在容器内部运行。

   这种容器运行微服务的架构提供来将服务用容器隔离的方法，容器内部包含了服务运行所有的环境依赖，也就是服务能够方便灵活迁移到任何Docker运行环境的关键。

   这种部署架构也带来了 ``全新`` 的运维方式，因为根本不能通过ssh访问容器内部，无法手工修改容器内部内容。只有重启容器来重启服务。这种运维方式改变会让很多运维人员感到不能适应，并且本能拒绝这种缺乏手工干预的运维方式。

   不过，如果你真正理解并且规范地使用Docker容器，并且通过标准的配置管理工具来运维容器，你就会发现这种规范的方法无形中杜绝了随意的线上手工操作，杜绝了不经过开发变更流程就可以更改线上系统的后门。所以，作为传统Unix/Linux系统管理员的我依然强烈建议你学习和使用这种规范的方式，努力 ``把自己从一个手工运维工作者转变成海量服务资源管理的开发工作者`` 。

以上的简单案例提供了一个Dockerfile的概览，其中 ``RUN`` 命令会影响镜像中文件系统，而 ``EXPOSE`` ， ``CMD`` ， ``WORKDIR`` 指令则影响镜像的元数据。

构建Docker image
--------------------

在上述Dockerfile完成基础上，执行以下命令来构建Docker image::

   docker build .

此时输出信息显示了完整的Docker层次结构的实现::

   Sending build context to Docker daemon  2.048kB
   Step 1/7 : FROM node
    ---> 9ba05fbb174a
   Step 2/7 : LABEL maintainer ian.miell@gmail.com
    ---> Running in 1195a5e7e5ba
   Removing intermediate container 1195a5e7e5ba
    ---> 61604c2a667e
   Step 3/7 : RUN git clone -q https://github.com/docker-in-practice/todo.git
    ---> Running in 110ae4d456c9
   Removing intermediate container 110ae4d456c9
    ---> a4fd654a02ec
   Step 4/7 : WORKDIR todo
    ---> Running in 089ee6b2cec0
   Removing intermediate container 089ee6b2cec0
    ---> 01941f38a2b9
   Step 5/7 : RUN npm install > /dev/null
    ---> Running in 4ce929827875 
   Removing intermediate container 4ce929827875
    ---> c08d4fa6be0c
   Step 6/7 : EXPOSE 8000
    ---> Running in f7dedd2426cd
   Removing intermediate container f7dedd2426cd
    ---> ae22e0c8369b
   Step 7/7 : CMD ["npm", "start"]
    ---> Running in 101ba6b2cb3c
   Removing intermediate container 101ba6b2cb3c
    ---> 91273f2a2a1d
   Successfully built 91273f2a2a1d

输出信息解释:

* 每一步命令的结果都会产生一个新的镜像，所以这里都会出现类似 ``---> 9ba05fbb174a`` 表示新的Image ID输出
* 为了节约存储空间，每个中间层容器会在下一步进行之前删除掉，所以会看到类似 ``Removing intermediate container 1195a5e7e5ba`` 这个操作
* 最后输出的Image ID层显示构建成功（最后一行） ``Successfully built 91273f2a2a1d`` ，这个最终的Image ID就是我们需要 ``tag`` 的Image Layer

最终，我们得到的Docker镜像的Image ID是 ``91273f2a2a1d`` （如果你实践得到的ID会不同），使用以下命令检查当前系统的镜像::

   docker images

显示输出::

   REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
   <none>              <none>              91273f2a2a1d        3 hours ago         952MB
   node                latest              9ba05fbb174a        12 days ago         900MB

可以看到 ``91273f2a2a1d`` ID不容易理解和使用，并且没有 ``tag`` 也就不容易引用，通过以下命令设置 ``tag`` 名字为 ``todoapp`` ::

   docker tag 91273f2a2a1d todoapp

此时再次使用 ``docker images`` 检查输出情况如下::

   REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
   todoapp             latest              91273f2a2a1d        3 hours ago         952MB
   node                latest              9ba05fbb174a        12 days ago         900MB

运行Docker容器
=====================

在完成上述 ``build`` 和 ``tag`` 首个Docker镜像之后，现在可以从镜像上启动一个容器::

   docker run -i -t -p 8000:8000 --name example1 todoapp

上述命令参数解释解释:

-i               表示交互模式 ``interact`` ，也就是容器运行后会停留在控制台，此时可以通过 ``ctrl-c`` 终止容器
-t               表示分配一个 ``pseudo-TTY`` 伪终端，也可以使用 ``--tty`` 参数方法
--name           给这个新创建的容器一个唯一命名 ``exmaple1``
-p               表示将容器的端口 ``8000`` 映射到host主机的端口 ``8000``

最后的 ``todoapp`` 则是我们已经 ``tag`` 命名的镜像层

输出显示::

   > todomvc-swarm@0.0.1 prestart /todo
   > make all
   ...
   Swarm server started port 8000

由于使用了参数 ``-i -t`` 参数，所以容器启动运行后停留在控制台能够接收控制台信号，也就是可以通过 ``ctrl-c`` 来终止容器。

切换到另外一个ssh到服务器的登陆终端，执行以下命令检查运行的容器::

   docker ps

可以看到输出::

   CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                    NAMES
   da1a5960034e        todoapp             "npm start"         12 minutes ago      Up 12 minutes       0.0.0.0:8000->8000/tcp   example1

输出中可以看到:

* 镜像 ``IMAGE`` 是 ``todoapp``
* 命令 ``COMMAND`` 是该镜像文件 ``Dockerfile`` 的最后一行命令 ``CMD ["npm", "start"]``
* 容器的名字 ``NAMES`` 是从镜像创建容器的命令行参数 ``--name example1`` 所指定的
* 容器和host主机之间的端口映射 ``PORTS`` 就是从镜像创建容器的命令行参数 ``-p 8000:8000`` ，可以看到对应的参数输出信息是 ``0.0.0.0:8000->8000/tcp``

现在，我们在原先启动容器的控制台按下 ``ctrl-c`` 终止容器运行。

此时，在host主机上再次执行 ``docker ps`` 就看到系统中当前没有运行容器（输出为空）。但是，这并不是表示容器被销毁了，因为使用 ``docker ps --all`` 或 ``docker ps -a``  可以看到输出如下::

   CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
   da1a5960034e        todoapp             "npm start"         21 minutes ago      Exited (0) 21 seconds ago                       example1

既然容器 ``example1`` 只是停止并没有销毁，我们可以再次启动该容器。这次启动容器时候不是使用 ``docker run`` 创建命令，而是使用 ``docker start`` 启动命令::

   docker start example1

请注意，此时启动 ``example1`` 这个容器的命令是直接返回控制台的，容器在后台运行，使用 ``docker ps`` 可以看到输出::

   CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                    NAMES
   da1a5960034e        todoapp             "npm start"         36 minutes ago      Up 2 seconds        0.0.0.0:8000->8000/tcp   example1

可以检查镜像上启动的容器之后，在容器中所有变化过的文件信息，使用命令 ``docker diff`` 命令如下::

   docker diff example1

显示输出::

   C /root
   C /root/.npm
   A /root/.npm/_logs
   A /root/.npm/_logs/2019-02-18T07_14_13_979Z-debug.log
   A /root/.npm/_logs/2019-02-18T07_15_56_608Z-debug.log
   C /root/.npm/anonymous-cli-metrics.json
   C /root/.npm/index-v5
   ...

这里每行开头字母是 ``C`` 表示 ``changed`` ，即修改的文件；每行开头字母 ``A`` 表示 ``added`` ，即添加的文件。

可以看到Docker包含了所有环境，并且跟踪了环境中的文件变化，这提供了我们管理软件生命周期的能力。

Docker层
===========

Docker的层功能解决了一个容器伸缩性的难题：

容器可以迅速启动的原因是Docker采用了 ``copy-on-write`` 的机制来降低存储消耗。运行的Docker容器写入文件时，它会记录下修改的内容并把修改部分记录到磁盘的新区域。当Docker执行 ``commit`` 指令时，Docker就会冻结这部分新的磁盘区域，并记录这个数据层。

数据层使得在一个镜像之上创建的所有容器都共享来这部分数据，每个容器的区别只是启动容器之后修改的部分。所以在Host主机上，不需要从基础Image实际复制出不同的容器，而是直接启动容器，只记录容器修改的部分。这种本地缓存的共享Image方式极大地加快了创建新容器的速度，也减少了存储消耗。

.. image:: ../_static/docker/docker_copy_on_write.png
   :scale: 50

镜像的分层模式也加快了软件更新的分发：

当更新Docker镜像，新的镜像并不需要重新分发到集群各个服务器上，只需要将更新的新层分发到host主机，就可以实现软件更新。如果在一个Host上支持不同的客户，需要不同的定制，则基础层部分可以共享，通过上层Docker来区分不同客户容器。
