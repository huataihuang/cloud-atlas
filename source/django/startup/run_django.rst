.. _run_django:

===============
运行Django
===============

.. note::

   对于Django，初始化整个项目称为 ``startproject`` ，此时默认会在项目下生成一个和项目同名的 ``app``

   初始化项目下的某个应用功能，例如 ``api`` ，则在项目目录下执行 ``startapp`` ，例如，如果要使用 :ref:`drf_quickstart` 则执行::

       django-admin.py startapp api

- 创建开发项目

Djang提供了一个命令行工具来创建一个项目，这里我们构建的是一个清单程序，所以命名项目 ``superlists`` ::

   django-admin.py startproject superlists

上述命令会创建目录 ``superlists`` 并在这个目录下还有一个同名的 ``superlists`` 子目录：这个 ``superlists/superlists`` 文件夹就是用来保存应用的整个项目的文件。

在 ``superlists`` 目录下 ``manage.py`` 程序，这个程序是负责Django环境管理和运行的。

- 数据库同步(Apply all migrations: admin, auth, contenttypes, sessions)::

   python manage.py migrate

- 运行开发服务器::

   python manage.py runserver

此时，再次运行 ``python functional_tests.py`` 则可以看到启动的Firefox正确打开了Django页面。

创建Git仓库
=============

现在把程序提交到git仓库( ``functional_tests.py`` 移动到 ``superlists`` 目录下然后再执行 )::

   git init .

git仓库初始化之后，提交文件前需要先把不合适提交的数据敏感文件剔除，例如 ``superlists/db.sqlite3`` ::

   echo "db.sqlite3" >> .gitignore
   echo "__pycache__" >> .gitignore
   echo "*.pyc" >> .gitignore

如果没有剔除不需要添加的文件，例如 ``superlists/superlists/__pycache__`` 目录下的文件，则使用以下命令删除::

   git rm -r --cached superlists/superlists/__pycache__

然后添加文件::

   git add .
   git status

检查没有问题，就提交::

   git commit

此时填写提交的简述。

如果要提交到远程github上，参考github的文档。

Docker Compose运行开发环境
===========================

我们通过部署 :ref:`django_env` 来 :ref:`run_django` ，但是每次这样重复创建环境也是非常麻烦的事情。并且，部署到测试环境、生产环境，都是重复的工作。我们通过 :ref:`docker` 可以 :ref:`docker_django_quickstart` 。
