.. _django_migrate:

===================
Django Migrations
===================

我们已经开始运行了一个简单的Django应用，你会注意到为了构建应用数据库，我们使用了命令 ``python manage.py migrate`` 。

Migrations概念
===============

所谓 ``Migrations`` 是指Django将models的修改(添加字段、删除模型)转换到数据库schema(模式)的方法。migrate通常设计是自动的，但是你需要如何创建migrations，何时需要运行migrate，以及出现问题时如何解决。

migrations流程
===============

- 构建 model

在Django中，我们不需要手工去创建数据库，而是先构建一个 model ，即在 ``models.py`` 中我们定义数据库结构

.. literalinclude:: django_migrate/models.py
   :language: python

- 然后我们执行 ``makemigrations`` 创建对应的数据库initial.py:

.. literalinclude:: django_migrate/makemigrations
   :language: bash
   :caption: 执行 makemigrations

此时会自动在 ``migrations`` 目录下生成生成一个 ``0001_initial.py`` 文件，类似

.. literalinclude:: django_migrate/0001_initial.py
   :language: python

- 执行数据库操作::

   python manage.py migrate

这个命令会根据生成的 ``0001_initial.py`` 对数据库进行操作，创建表格和对应字段。

- 检查项目的migrations以及状态::

   python manage.py showmigrations

这个命令会输出所有的migrations以及状态(是否执行过)

``makemigrations`` 报错处理
-----------------------------

我在最近的一次实践中，对一个老项目重新部署，在完成数据库初步准备之后(创建数据库以及设置好账号密码)，执行 ``python manage.py makemigrations`` 出现报错:

.. literalinclude:: django_migrate/makemigrations_err
   :caption: 执行 makemigrations 报错

这个问题在 `ImportError: cannot import name 'url' from 'django.conf.urls' after upgrading to Django 4.0 <https://stackoverflow.com/questions/70319606/importerror-cannot-import-name-url-from-django-conf-urls-after-upgrading-to>`_ 有解释，原因是Django 3.0升级到Django 4.0+之后已经废弃了 ``django.conf.urls.url()`` 。由于是老项目，我采用 :ref:`pip` Downgrade Django版本方式来解决

Migrations后端支持
===================

Migrations屏蔽了Django使用的数据库后端差异，通过完全相同的 model ，我们可以配置不同的数据库后端，实现对不同数据库的schema构建和修改。

清空数据和重新migrations同步
==============================

在开发过程中，我们可能会需要清空数据库并重新migrate，步骤如下

- 删除项目的数据库表，这里举例是 ``api`` 项目(如果要保留数据，可以不执行这步)
- 删除项目的migrations目录下所有文件，但保留 ``__init__.py``
- 重建migrate初始化文件::

   python manage.py makemigrations

- 检查migrate状态(这里 ``api`` 是项目名字)::

   python manage.py showmigrations api

- 因为之前已经执行过migrate命令，所以同名的migrate都是已经执行状态，我们需要重置成空的状态::

   python manage.py migrate --fake api zero

然后再次检查migrate状态就会看到 ``api`` 对应的migrate状态是空的::

   python manage.py showmigrations api

- 重新生成migrate文件::

   python manage.py makemigrations api

此时重新生成的 ``0001_initial.py`` 文件会反映修订过的 ``models.py`` 内容(假如你调整了数据库表结构)

- 重新执行数据库同步::

   python manage.py migrate

.. note::

   如果你只想重新生成migrate文件，但是不执行到数据库，则使用::

      python manage.py --fake-initial api

参考
======

- `Django Documentation: Migrations <https://docs.djangoproject.com/en/3.1/topics/migrations/>`_
- `Django清空所有数据或重置migrations同步 <https://www.jianshu.com/p/7aa23f044cef>`_
- `Django Migrations: A Primer <https://realpython.com/django-migrations-a-primer/>`_
