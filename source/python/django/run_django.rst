.. _run_django:

===============
运行Django
===============

Djang提供了一个命令行工具来创建一个项目，这里我们构建的是一个清单程序，所以命名项目 ``superlists`` ::

   django-admin.py startproject superlists

上述命令会创建目录 ``superlists`` 并在这个目录下还有一个同名的 ``superlists`` 子目录：这个 ``superlists/superlists`` 文件夹就是用来保存应用的整个项目的文件。

在 ``superlists`` 目录下又一个 ``manage.py`` 程序，这个程序可以运行开发服务器::

   python manage.py runserver

此时有一个提示::

   You have 17 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, contenttypes, sessions.
   Run 'python manage.py migrate' to apply them.

   January 16, 2020 - 15:02:28
   Django version 3.0.2, using settings 'superlists.settings'
   Starting development server at http://127.0.0.1:8000/
   Quit the server with CONTROL-C.

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
