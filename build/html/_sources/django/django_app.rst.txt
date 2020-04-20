.. _django_app:

=================
Django 应用
=================

Django建议采用 "应用" 的形式组织代码，也就是在一个项目中存放多个应用，并且可以使用其他人开发的第三方应用，或者重用自己在其他项目中开发的应用。

- 创建时间清单应用::

   python manage.py startapp lists

我在macOS上采用 :ref:`docker_compose_django` 部署应用 ，也在本机运行pyhont开发环境，所以我在virtualenv中安装了 ``mysqlclient`` 执行上述命令。提示错误::

   Traceback (most recent call last):
     File "/Users/huataihuang/venv3/lib/python3.7/site-packages/django/db/backends/mysql/base.py", line 16, in <module>
         import MySQLdb as Database
     File "/Users/huataihuang/venv3/lib/python3.7/site-packages/MySQLdb/__init__.py", line 18, in <module>
       from . import _mysql
   ImportError: dlopen(/Users/huataihuang/venv3/lib/python3.7/site-packages/MySQLdb/_mysql.cpython-37m-darwin.so, 2): Library not loaded: @rpath/libmysqlclient.21.dylib
   Referenced from: /Users/huataihuang/venv3/lib/python3.7/site-packages/MySQLdb/_mysql.cpython-37m-darwin.so
   Reason: image not found
   ...
   File "/Users/huataihuang/venv3/lib/python3.7/site-packages/django/db/backends/mysql/base.py", line 21, in <module>
      ) from err
   django.core.exceptions.ImproperlyConfigured: Error loading MySQLdb module.
   Did you install mysqlclient?

``virtualenv`` 环境实际已经安装了 ``mysqlclient`` ，但是为何还会报错？

仔细查看报需哦信息中有::

   ImportError: dlopen(/Users/huataihuang/venv3/lib/python3.7/site-packages/MySQLdb/_mysql.cpython-37m-darwin.so, 2): Library not loaded: @rpath/libmysqlclient.21.dylib

这个 ``libmysqlclient.21.dylib`` 位于macOS安装的MySQL软件路径 ``/usr/local/mysql/lib`` 中。在Linux平台，我们通常会通过如下方式告知操作系统库文件路径::

   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/mysql/lib

不过，在OS X系统中，使用的环境变量是 ``DYLD_LIBRARY_PATH`` (参考 `Is it OK to use DYLD_LIBRARY_PATH on Mac OS X? And, what's the dynamic library search algorithm with it? <https://stackoverflow.com/questions/3146274/is-it-ok-to-use-dyld-library-path-on-mac-os-x-and-whats-the-dynamic-library-s>`_ ) 。所以，修改 ``~/.zshrc`` 添加::

   export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/mysql/lib

然后再次执行 ``python manage.py startapp lists`` 就可以成功在项目目录下创建子目录 ``lists`` ，并且与 ``superlists`` 子目录并列。检查lists子目录，可以看到占位文件，用来保存模型、视图和测试。

.. note::

   单元测试和功能测试的区别：

   - 功能测试站在用户角度，从外部测试应用
   - 单元测试站在程序员角度，从内部测试应用
   
   功能测试的作用是帮助你开发具有所需功能的应用，以保证你不会无意中破坏这些功能。单元测试的作用是帮助你编写简洁无错的代码。

一个简单的功能测试
====================

- ``lists/tests.py`` ::

   from django.test import TestCase

   # Create your tests here.

   class SmokeTest(TestCase):
       def test_bad_maths(self):
           self.assertEqual(1 + 1, 3)

执行 ``python manage.py test`` 会出现报错::

     File "/Users/huataihuang/venv3/lib/python3.7/site-packages/django/db/backends/base/creation.py", line 153, in _get_test_db_name
         return TEST_DATABASE_PREFIX + self.connection.settings_dict['NAME']
     TypeError: can only concatenate str (not "NoneType") to str

这个报错是因为没有执行过 ``python manage.py migrate`` 导致的，在安装了MySQL数据库并且切换了 ``<project_name>/settings.py`` 的数据库设置之后，需要先执行一次数据库迁移。

数据库初始化请参考 :ref:`install_mysql` 。

不过，执行完 ``python manage.py migrate`` 之后，再执行 ``python manage.py test`` 出现权限报错::

   Creating test database for alias 'default'...
   Got an error creating the test database: (1044, "Access denied for user 'ttd'@'%' to database 'test_ttdpython'")

我暂时采用了放宽权限的方式 ``grant all privileges on *.* to myapp_user@'%';`` 绕过这个问题，具体权限有待探索。

现在我们可以执行上述验证错误django test，可以看到 ``unittest`` 提供了功能测试输出(这里只是验证功能测试工作了，后面实际上要修改成真正有意义的功能测试)::

   Creating test database for alias 'default'...
   System check identified no issues (0 silenced).
   F
   ======================================================================
   FAIL: test_bad_maths (lists.tests.SmokeTest)
   ----------------------------------------------------------------------
   Traceback (most recent call last):
     File "/Users/huataihuang/go/src/github.com/ttd-python/lists/tests.py", line 7, in test_bad_maths
       self.assertEqual(1 + 1, 3)
   AssertionError: 2 != 3
   
   ----------------------------------------------------------------------
   Ran 1 test in 0.004s
   
   FAILED (failures=1)
   Destroying test database for alias 'default'...   

有意义的功能测试
==================

- ``list/test.py`` 修订::

   from django.urls import resolve
   from django.test import TestCase
   from lists.views import home_page
   
   # Create your tests here.
   
   class HomePageTest(TestCase):
       def test_root_url_resolve_to_home_page_view(self):
           found = resolve('/')
           self.assertEqual(found.func, home_page)

.. note::

   Django 2.0移除了 ``django.core.urlresolvers`` 模块，改到了 ``django.urls`` 模块。参考 `ImportError: No module named 'django.core.urlresolvers' <https://stackoverflow.com/questions/43139081/importerror-no-module-named-django-core-urlresolvers>`_

``resolve`` 是Django内部函数，用于解析URL，并将其映射到相应的视图函数上。上例解析网站的根路径 / 是否能找到名为 ``/home_page`` 的函数。这个函数是视图函数，其作用是返回所需的HTML。

从 ``from lists.views import home_page`` 可看到，这个函数保存在 ``lists/views.py`` 中。

视图 lists/view.py
====================

为了测试我们的
