.. _django_mysql:

==========================
Django配置MySQL数据库
==========================

在部署 :ref:`django_env_linux` 后，我们可以开发Django。但是，默认使用的数据库是sqlite，和生产环境往往不同。所以，我们通常会把Django数据库后端替换成MySQL。

但是，需要注意的是，我们不能把数据库访问账号密码直接配置在 ``manage.py`` 中，也不能把包含账号信息提交到git仓库中，所以需要有一定的配置方法来实现数据库连接。

准备数据库
==============

- 使用以下方式创建应用数据库::

   create database myappdb character set utf8;
   create user myapp@'%' identified by 'MyPass';
   grant all privileges on myappdb.* to myapp@'%';
   flush privileges;

安装mysqlclient模块
====================

在安装 :ref:`virtualenv` 之后，通过 ``pip``  安装 ``mysqlclient`` 模块::

   pip install mysqlclient

如果出现报错::

    ERROR: Command errored out with exit status 1:
     command: /home/admin/venv3/bin/python -c 'import sys, setuptools, tokenize; sys.argv[0] = '"'"'/tmp/pip-install-3m5z471x/mysqlclient_891b537df843484ba930dc9520c76710/setup.py'"'"'; __file__='"'"'/tmp/pip-install-3m5z471x/mysqlclient_891b537df843484ba930dc9520c76710/setup.py'"'"';f=getattr(tokenize, '"'"'open'"'"', open)(__file__);code=f.read().replace('"'"'\r\n'"'"', '"'"'\n'"'"');f.close();exec(compile(code, __file__, '"'"'exec'"'"'))' egg_info --egg-base /tmp/pip-pip-egg-info-1mbvlvf_
         cwd: /tmp/pip-install-3m5z471x/mysqlclient_891b537df843484ba930dc9520c76710/
    Complete output (15 lines):
    /bin/sh: mysql_config: command not found
    /bin/sh: mariadb_config: command not found
    /bin/sh: mysql_config: command not found
    mysql_config --version
    mariadb_config --version
    mysql_config --libs 

则需要安装 mysql 开发包，例如 ``mariadb-devel`` ，安装以后系统会有 ``mysql_config`` 工具:

.. literalinclude:: django_mysql/install_mysql-devel
   :caption: 需要提前安装 ``mysql-devel`` 或 ``mariadb-devel`` 才能执行 ``pip install mysqlclient``

.. note::

   在 :ref:`django_env_linux` 对于 ``pip install mysqlclient`` 有处理案例

.. warning::

   我最近的实践发现在CentOS 7环境提供的是 MariaDB，此时编译安装 ``mysqlclient`` 模块始终报错，参考 `How to connect Python programs to MariaDB <https://mariadb.com/resources/blog/how-to-connect-python-programs-to-mariadb/>`_ ，看起来社区采用了新的 ``mariadb`` 来连接MariaDB，我以为 ``mysqlclient`` 已经不能兼容。 **实际上并不是这样** ， ``mysqlclient`` 需要采用 ``MariaDB`` 的较高版本才能正常编译。我验证 :ref:`install_mariadb` v10.11 则编译安装没有任何问题。

解决 ``mysqlclient`` 模块安装
------------------------------

.. warning::

   我这里的挫折实际上是因为我采用了CentOS(aliOS 7.2)发行版内置的 ``MariaDB`` v5.5 导致的，浪费了我两天时间。实际上，当重新 :ref:`install_mariadb` v10.11 之后问题引刃而解。

这次遇到一个报错，和之前 :ref:`django_mysql` 不同:

.. literalinclude:: django_env_linux/mysqlclient_error
   :caption: ``pip`` 安装 ``mysqlclient`` 报错
   :emphasize-lines: 10-13

这里可以看到 ``pkg-config --exists mysqlclient`` 和 ``pkg-config --exists mariadb`` 都是返回 ``1`` (失败)。我手工执行了一下，确实 ``echo $?`` 显示 ``1``

仔细一看，原来这个  ``pkg-config`` 是操作系统默认的 ``/usr/bin/pkg-config`` 。这里通过 ``rpm -qf /usr/bin/pkg-config`` 可以看出是属于 ``pkgconfig-0.27.1-4.1.alios7.x86_64`` ，显然不会获得正确的包信息

`PyMySQL / mysqlclient / README.md <https://github.com/PyMySQL/mysqlclient/blob/main/README.md>`_ 提供了一个线索:

.. literalinclude:: django_env_linux/pkg-config_mysqlclient
   :caption: 定制编译时指定环境变量

既然由于操作系统的 ``pkg-config`` 无法正常工作，那么该如何设置环境变量呢?

我找了自己部署的一台 :ref:`fedora` 开发环境( :strike:`吐槽一下公司魔改的CentOS` 社区CentOS 7确实存在这个问题)，可以看到:

.. literalinclude:: django_env_linux/pkg-config_mariadb
   :caption: 在正确的环境中执行 ``pkg-config`` 获取环境变量
   :emphasize-lines: 2,4

- 所以修正安装方法:

.. literalinclude:: django_env_linux/pkg-config_mariadb_env
   :caption: 设置正确 ``mysqlclient`` 环境变量

- :strike:`然后再次执行就可以完成` 不过我再次执行安装报错似乎不兼容:

.. literalinclude:: django_env_linux/mysqlclient_error_again
   :caption: 提供了mysqlient的编译环境变量，但是编译报错
   :emphasize-lines: 46-55

这个问题我最后做了多次安装对比，发现是旧版本 ``mariadb`` 的bug，当采用 :ref:`install_mariadb` 采用社区仓库并安装 MariaDB 10.11 之后，这个问题引刃而解。

配置Django连接数据库
=====================

- django一般有2种方式获取数据库连接信息:

  - 直接读取 ``/etc/my.cnf`` (当前Django官方推荐) : 例如这里可以创建一个 ``myapp.cnf`` 配置文件，对应上文创建的 ``myappdb`` 数据库访问账号
  - 使用环境变量

.. _django_mysqlclient_config:

Django使用MySQL Client配置(推荐)
-----------------------------------

现在Django推荐采用直接读取操作系统安装的MySQL客户端配置来完成数据库连接配置。例如，通常我们的数据库访问配置 ``/etc/my.cnf`` 内容如下::

   [client]
   database = NAME
   user = USER
   password = PASSWORD
   default-character-set = utf8

- 修改 ``myapp/settings.py`` 数据库配置::

    DATABASES = {
        'default': {
             'ENGINE': 'django.db.backends.mysql',
             'OPTIONS': {
                 'read_default_file': '/etc/onesredb.cnf',
             },
        }
    }

Django使用数据库环境变量
---------------------------

django支持从环境变量中读取配置，所以可以将密码相关变量保存到环境中。对于使用Python virtualenv，可以在进入虚拟环境的最后激活配置 ``postactivate`` 中设置环境，并在 ``predeactivate`` 文件中 ``unset`` 环境变量。

- 修订django的 ``myapp/settings.py`` 将::

   DATABASES = {
       'default': {
           'ENGINE': 'django.db.backends.sqlite3',
           'NAME': BASE_DIR / 'db.sqlite3',
       }
   }

修改成::

   DATABASES = {
       'default': {
           'ENGINE': 'django.db.backends.mysql',
           'NAME': get_env_variable('DATABASE_NAME'),
           'USER': get_env_variable('DATABASE_USER'),
           'PASSWORD': get_env_variable('DATABASE_PASSWORD'),
           'HOST': '',
           'PORT': '',
       }
   }

- 在 ``myapp/settings.py`` 开头加上::

   from django.core.exceptions import ImproperlyConfigured
    
   def get_env_variable(var_name):
       try:
           return os.environ[var_name]
       except KeyError:
           error_msg = "Set the %s environment variable" % var_name
           raise ImproperlyConfigured(error_msg)

- 最后在virtualenv虚拟机环境 ``venv3/bin/postactive`` 中加上数据库设置::

   export DATABASE_NAME='myappdb'
   export DATABASE_USER='myapp'
   export DATABASE_PASSWORD='MyPass'

- 并在virtualenv虚拟机退出配置 ``venv3/bin/predeactivate`` 配置加上::

   unset DATABASE_NAME
   unset DATABASE_USER
   unset DATABASE_PASSWORD

数据库迁移
-------------

在完成上述两种数据库连接配置之一后，执行以下命令进行数据库migration::

   python manage.py migrate

最后测试应用启动::

   python manage.py runserver

参考
======

- `Install and Configure MySQL for Django <http://www.marinamele.com/taskbuster-django-tutorial/install-and-configure-mysql-for-django>`_ - 通过环境变量设置数据库连接
- `How To Create a Django App and Connect it to a Database <https://www.digitalocean.com/community/tutorials/how-to-create-a-django-app-and-connect-it-to-a-database>`_
- `Connecting to the database <https://docs.djangoproject.com/en/3.1/ref/databases/#connecting-to-the-database>`_
