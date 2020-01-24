.. _docker_compose_django:

========================
在Docker环境运行Django
========================

.. note::

   本文实践采用 :ref:`docker_compose` 完成设置，运行一个简单的Django/MySQK应用。

   请参考 :ref:`django_env` 完成设置，并确保能够 :ref:`run_django` 。

在Docker环境中运行Django，需要创建Dockerfile，Python依赖文件，以及 ``docker-compose.yml`` 文件。

定义项目组件
==============

在项目目录下，需要创建一个 ``Dockerfie`` ，定义了应用程序的镜像名以及更多的build命令来定制镜像。一旦构建之后，就可以在容器中运行镜像。

- ``Dockerfile`` 内容如下:

.. literalinclude:: ./Dockerfile
   :language: bash
   :linenos:

这里的 ``Dockerfile`` 开始部分使用了 `Python 3 parent image <https://hub.docker.com/r/library/python/tags/3/>`_ ，这个父镜像通过添加 ``code`` 目录，然后安装通过 ``requirements.txt`` 文件定义的Python运行依赖。

- 在项目目录下创建 ``requirements.txt`` ，例如，我的app项目内容如下:

.. literalinclude:: ./requirements.txt
   :language: bash
   :linenos:

这个Python运行依赖定义文件是通过 ``RUN pip install -r requirements.txt`` 执行的。

- 创建 ``docker-compose.yml`` 配置

``docker-compose.yml`` 文件描述应用服务，这里是web服务和数据库服务。compose文件描述了服务使用的Docker镜像，连接方式，以及在容器中挂载的卷。最后 ``docker-compose.yml`` 文件还描述了输出服务的端口。

``docker-compose.yml`` :

.. literalinclude:: ./docker-compose.yml
   :language: yaml
   :linenos:

.. note::

   后文我详细解释配置项用途。

创建Django项目
=======================

通过上述 ``docker-compose.yml`` 定义的image以及服务依赖关系，我们现在就可以创建Django项目( 通过 ``docker-compose run`` 命令可以在容器中执行命令) ::

   docker-compose run web django-admin startproject myapp .

上述指令在容器中运行了 ``django-admin startproject myapp`` ，并且使用了web服务镜像和配置。初次运行时，web镜像还不存在。则Compose就会在当前目录下构建，因为这里在 ``docker-compose.yml`` 中指定了 ``build: .`` 。

.. note::

   由于我已经 :ref:`django_env` 完成设置，并确保能够 :ref:`run_django` ，所以我在这里执行的命令是::

      docker-compose run web

   这样就跳过了 ``django-admin startporject myapp .`` 初始化Django项目，直接使用之前已经创建好的Django环境。

运行提示::

   WARNING: You are using pip version 19.3.1; however, version 20.0.1 is available.
   You should consider upgrading via the 'pip install --upgrade pip' command.

   Successfully built adb7f7c47877
   Successfully tagged onesre_web:latest
   WARNING: Image for service web was built because it did not already exist. To rebuild this image you must use `docker-compose build` or `docker-compose up --build`.
   Watching for file changes with StatReloader
   Performing system checks...

   System check identified no issues (0 silenced).
   January 22, 2020 - 08:34:52
   Django version 3.0.2, using settings 'onesre.settings'
   Starting development server at http://0.0.0.0:8000/
   Quit the server with CONTROL-C.

注意，此时还不能打开 http://0.0.0.0:8000/ 。但是，通过 ``docker exec -it <CONTAINER_ID> /bin/sh`` 登陆到容器内部，检查 ``ps aux | grep pyton`` 可以看到服务进程::

   root         1  0.0  1.7  43568 35648 pts/0    Ss+  13:18   0:00 python manage.py runserver 0.0.0.0:8000
   root         9  4.4  1.8 118980 38520 pts/0    Sl+  13:18   0:50 /usr/local/bin/python manage.py runserver 0.0.0.0:8000

这说明容器内部服务已经正常启动，但是docker没有实现port map。仔细看了 ``docker ps`` ，可以看到仅仅是启动了 ``myapp_web`` 容器。所以，此时没有启动db情况下，还没有做docker的端口映射。

MySQL容器化运行
==================

.. note::

   参考 `dockerhub MySQL 说明 <https://hub.docker.com/_/mysql/>`_ 可以看到，官方mysql镜像支持通过环境变量传递初始化密码和数据库名。

- ``docker-compose.yml`` 的以下高亮黄色的两行是读取环境 ``db.env`` 配置:

.. literalinclude:: ./docker-compose.yml
   :language: yaml
   :emphasize-lines: 8-9
   :linenos:

.. note::

   虽然 docker compose 支持直接在 ``docker-compose.yml`` 中直接配置环境变量，但是通常会把 ``docker-compose.yml`` 文件提交到软件仓库，这样存在安全隐患。

   所以，我们采用 ``env_file`` 方式引用一个不会添加到git仓库的文件，例如 ``db.env`` ，内容包含如下:
      
   .. literalinclude:: ./db.env
      :language: bash
      :linenos:

   然后，在 ``.gitignore`` 中添加一行内容 ``db.env`` 避免该文件被提交到git仓库，以保证安全。

   Compose 环境变量请参考 `Environment variables in Compose <https://docs.docker.com/compose/environment-variables/>`_

- 启动数据库::

   docker-compose run db

此时会看到mysql数据库按照环境配置启动并初始化。完成后请执行::

   docker exec -it <CONTAINER_ID> /bin/bash

进入数据库服务器，然后执行::

   mysql mydb -umyapp_user -pmyapp_passwd

验证数据库连接和运行，并且可以执行简单的查询。

数据库连接
===========

- 默认Django数据库连接是本地sqlite，通过配置项目目录下 ``myapp/settings.py`` 文件的 ``DATABASES = ...`` 部分来连接数据库

Django密码安全secrets.json
------------------------------

由于Django项目的 ``settings.py`` 也同样提交的git仓库，则为了避免风险，需要将数据库配置部分分离到独立配置文件，并且这个数据库账号配置文件不可提交到git仓库。

参考 `Django, Security and Settings <https://stackoverflow.com/questions/42077532/django-security-and-settings>`_ ，有两种方法实现Django敏感数据：

环境变量设置数据库密码
~~~~~~~~~~~~~~~~~~~~~~~~

- 如果你没有使用docker来运行django，则通常可以在 ``~/.bash_profile`` 中设置环境变量，这样启动Django也是能获得数据库密码账号::

   export MYSQL_PASSWORD=myapp_passwd

- 修订 ``settings.py`` 导入配置::

   ...
   DATABASES = {
       'default': {
           'ENGINE': 'django.db.backends.mysql',
           'NAME': os.getenv('MYSQL_DATABASE'),
           'USER': os.getenv('MYSQL_USER'),
           'PASSWORD': os.getenv('MYSQL_PASSWORD'),
           'HOST': 'db',
           'PORT': '3306',
       }
   }

这样启动后Django就可以从环境变量中获取账号密码。

.. note::

   `How do I pass environment variables to Docker containers? <https://stackoverflow.com/questions/30494050/how-do-i-pass-environment-variables-to-docker-containers>`_ 介绍了多种方法传递环境变量到Docker容器内部。在docker docs文档中提供案例： `Set environment variables (-e, --env, --env-file) <https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file>`_

      docker run -e MYVAR1 --env MYVAR2=foo --env-file ./env.list ubuntu bash

   这里的案例，你可以设置一个 ``DB_PASSWORD=myapp_passwd`` 环境变量，然后执行docker

同样，参考前面针对 ``db`` 服务的环境变量设置， ``docker-compose`` 也支持读取环境变量，我们可以创建一个 ``web.env`` 保存Django的数据库环境变量(实际上就是 ``db.env`` 配置的部分内容)。为了能够简化配置，我们可以复用 ``db`` 服务的环境配置(所以这里就用了相同的环境变量名)。

启动服务
===========

集中上述配置，现在我们可以启动 ``docker-compose.yml`` 配置的 db 和 web 服务::

   docker-compose up

此时通过浏览器访问 http://127.0.0.1:8000/ 可以看到Django欢迎页面：

.. figure:: ../../_static/docker/applications/docker_compose_django.png
   :scale: 75

注意，这里控制台提示信息::

   web_1  | You have 17 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, contenttypes, sessions.
   web_1  | Run 'python manage.py migrate' to apply them.

这说明我们遗漏了一步数据库迁移，所以我们先停止掉 db 和 web 容器，然后执行一次django数据库迁移::

   docker-compose run web python manage.py migrate

这个步骤会自动启动数据库，然后执行django迁移，完成后再次启动 ``docker-compose up`` 就可以正常使用。

- 停止应用的方法可以通过在控制台按下 ``Ctrl-C``  来停止容器，另外也有一种比较优雅的方法，就是使用 ``docker-compose`` 命令，即启动另外一个shell窗口，还是在这个目录下执行::

   docker-compose down

.. _docker_django_quickstart:

快速实现Docker运行Djgnao
===========================

上述的部署过程比较曲折，以下为总结，可以快速完成 django + mysql 部署。

- ``Dockerfile`` :

.. literalinclude:: ./Dockerfile
   :language: bash
   :linenos:

- ``requirements.txt`` (指示pip安装) :

.. literalinclude:: ./requirements.txt
   :language: bash
   :linenos:

- ``docker-compose.yml`` (构建容器关系，和数据库相关账号数据通过 ``db.env`` 引入):

.. literalinclude:: ./docker-compose.yml
   :language: yaml
   :linenos:

- ``db.env`` 配置db和web使用的账号和数据库配置:

.. literalinclude:: ./db.env
   :language: bash
   :linenos:

- 启动并初始化数据库::

   docker-compose run db

- 数据库初始化完成后，开启另外一个shell，在当前目录下停止容器::

   docker-compose down

- 初始化Django项目(在当前目录执行创建myapp应用)::

   docker-compose run web django-admin startproject myapp .

.. note::

   这个步骤将启动django进行项目初始化，并提示::

      Successfully built 6ab89519f3bd
      Successfully tagged myapp_web:latest  # 这里标签是根据当前目录 myapp  加上 _web

- 修改 Django 配置 ``myapp/settings.py`` ::

   ...
   DATABASES = {
       'default': {
           'ENGINE': 'django.db.backends.mysql',
           'NAME': os.getenv('MYSQL_DATABASE'),
           'USER': os.getenv('MYSQL_USER'),
           'PASSWORD': os.getenv('MYSQL_PASSWORD'),
           'HOST': 'db',
           'PORT': '3306',
       }
   }

- 执行django数据库迁移(该命令会依次启动db，然后再启动web服务进行django数据库初始化::

   docker-compose run web python manage.py migrate

- 可以停止数据库再次启动验证::

   docker-compose down
   docker-compose up

一切正常情况下，使用浏览器就可以访问Django最初的欢迎页面，后续进行开发

- 当代码迭代开发，则执行::

   docker-compose build

- 然后再次启动::

   docker-compose up

.. note::

   目前发现这个部署还是有一点问题，mysql数据库初始化( ``docker-compose build`` )较慢，导致web启动后连接数据库失败。不过第二次启动，MySQL无需初始化则启动迅速，则web正常工作。

参考
=======

- `Quickstart: Compose and Django <https://docs.docker.com/compose/django/>`_

