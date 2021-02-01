.. _introduce_drf:

=================================
Django REST framework(DRF)简介
=================================

.. figure:: ../../_static/django/rest_framework/drf-logo.png
   :scale: 75

`Django REST framework官网 <https://www.django-rest-framework.org>`_ （以下简称 DRF）是一个开源的 Django 扩展，提供了便捷的 REST API 开发框架，拥有以下特性：

- 直观的 API web 界面。
- 多种身份认证和权限认证方式的支持。
- 内置了 OAuth1 和 OAuth2 的支持。
- 内置了限流系统。
- 根据 Django ORM 或者其它库自动序列化。
- 丰富的定制层级：函数视图、类视图、视图集合到自动生成 API，满足各种需要。
- 可扩展性，插件丰富。
- 广泛使用，文档丰富。

运行要求
=============

REST framework运行要求：

- Python (3.5, 3.6, 3.7, 3.8, 3.9)
- Django (2.2, 3.0, 3.1)

建议使用Python和Django系列的最新patch发布版

以下软件包为可选:

- PyYAML, uritemplate (5.1+, 3.0.0+) - 支持Schema生成
- Markdown (3.0.0+) - 浏览API时支持Markdown
- Pygments (2.4.0+) - 在Markdown处理时增加语法高亮
- django-filter (1.0.1+) - 支持过滤 (强烈推荐)
- django-guardian (1.1.1+) - 支持对象级授权

安装DRF
=========

建议在 :ref:`virtualenv` 使用 ``pip`` 安装，包括可选软件包::

   pip install djangorestframework
   pip install markdown       # Markdown support for the browsable API.
   pip install payments
   pip install django-filter  # Filtering support

在 :ref:`django_env` 中 :ref:`run_django` 创建好开发项目，修改 ``settings.py`` 配置的 ``INSTALLED_APPS`` 段落::

   INSTALLED_APPS = [
       ...
       'rest_framework',
   ]

- 对于想要使用可浏览API，最好添加一个REST framework登陆视图，也就是在根目录

参考
=======

- `Django REST framework官网 <https://www.django-rest-framework.org>`_
