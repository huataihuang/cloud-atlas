.. _drf_quickstart:

==============================
Django REST framework快速起步
==============================

初始化
=========

.. note::

   初始化Django项目方法和 :ref:`run_django` 相同，所以如果已经在Django项目执行过 ``django-admin startproject XXX`` 则可以直接执行 ``startapp`` 来创建Django REST framework的子应用。

- 首先初始化一个 :ref:`virtualenv` ::

   python3 -m venv ~/venv3
   source ~/venv/bin/activate

   pip install django
   pip install djangorestframework

- 创建一个Django项目名为 ``django_atlas`` ，然后启动一个新的app名为 ``api`` ::

   django-admin startproject django_atlas
   cd django_atlas
   django-admin startapp api
   cd ..

此时在当前目录下有::

   django_atlas
   |- api目录
     |- 这个目录下有drf的一系列初始化文件
   |- django_atlas目录
     |- __init__.py
     |- asgi.py
     |- settings.py
     |- urls.py
     |- wsgi.py
   manage.py

- 创建一个初始化名为 ``admin`` 的用户::

   python manage.py createsuperuser --email admin@example.com --username admin

Serializers
=============

- 首先需要定义一些序列化，创建名为 ``django_atlas/api/serializers.py``

参考
=====

- `Django REST framework Quickstart <https://www.django-rest-framework.org/tutorial/quickstart/>`_
