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

配置Django连接数据库
=====================

- django一般有2种方式获取数据库连接信息:

  - 直接读取 ``/etc/my.cnf`` (当前Django官方推荐)
  - 使用环境变量

读取MySQL Client配置(推荐)
----------------------------

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

数据库环境变量
----------------

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
