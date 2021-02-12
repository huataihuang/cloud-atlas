.. _django_static:

================
Django静态文件
================

WEB网站的静态文件，例如图片，JavaScript或者CSS，对于Django来说，这些静态文件最好通过独立的WEB服务器，例如 :ref:`nginx` 来提供。这样能够充分发挥nginx的高性能，也降低Django自身的压力。

配置静态文件
===============

- 首先修改项目 ``settings.py`` 配置，在 ``INSTALLED_APPS`` 中确保包含了 ``django.contrib.staticfiles`` (这个默认已启用)

- 在 ``settings.py`` 配置中定义 ``STATIC_URL`` ::

   STATIC_URL = '/static/'

- 在模版中使用 ``static`` 模版tag来构建URL，并添加 ``STATICFILES_DIRS`` ::

   STATIC_URL = '/static/'
   STATICFILES_DIRS = (str(BASE_DIR.joinpath('static')),)

.. note::

   这里配置是针对 Django 3.1+，使用了 ``pathlab`` ，如果是 Django 3.0或以前版本，则使用 ``STATICFILES_DIRS = [os.path.join(BASE_DIR, 'static')]``

- 创建静态目录 ``static`` ，然后创建子目录 ``css`` , ``js`` , ``img`` ::

   mkdir static/css
   mkdir static/js
   mkdir static/img

- 在项目的模版文件中添加2处静态文件配置

  - 模版的开头添加 ``{% load static %}``
  - 在合适的链接处添加 ``{% static %}`` 模版tag

举例，在项目中使用了 ``base.html`` 则类似::

   <!-- templates/base.html -->
   {% load static %}
   <!DOCTYPE html>
   <html>
   <head>
     <title>Learn Django</title>
     <link rel="stylesheet" href="{% static 'css/base.css' %}">
   </head>
   ...
   </html>

此外，图片文件和JavaScripts文件位于 ``img`` 和 ``js`` 子目录，所以对应是::

   <img src="{% static 'img/path_to_img' %}">
   <script src="{% static 'js/base.js' %}"></script>

.. note::

   在本地开发过程中，请将所有静态文件都存放到 ``static`` 的上述3个子目录。这样本地开发可以继续进行。

   对于生产环境，只要执行下文的 ``collectstatic`` 命令，就会复制所有静态文件到 ``STATIC_ROOT`` 指定的目录，也就是 ``staticfiles`` 目录下。包括我们在本地开发时存储在 ``static`` 目录下的静态文件，这样在生产环境就可以正常使用了。

collectstatic
===============

需要注意，虽然本地Django服务器是提供静态文件服务的，但是对于生产环境， :ref:`nginx_gunicorn_django` 或者 :ref:`nginx_uwsgi_django` 都不会提供静态文件服务，而是通过 :ref:`nginx` 来提供。所以，Django内建了一个 ``collectstatic`` 命令来编译所有的静态文件到单一目录：

- 使用 ``STATIC_ROOT`` 配置设置搜集这些文件的绝对路径，通常称为 ``staticfiles``
- 最终配置是 ``STATICFILES_STORAGE`` 也就是使用文件存储引擎来保存这些使用 ``collectstatic`` 命令搜集的静态文件。默认，这个设置是 ``django.contrib.staticfiles.storage.StaticFilesStorage``

所以最终的 ``settings.py`` 配置如下::

   # settings.py
   STATIC_URL = '/static/'
   STATICFILES_DIRS = (str(BASE_DIR.joinpath('static')),) # new
   STATIC_ROOT = str(BASE_DIR.joinpath('staticfiles')) # new
   STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.StaticFilesStorage' # new

- 然后执行以下命令搜集静态文件::

   python manage.py collectstatic

此时会提示静态文件被复制到 ``STATIC_ROOT`` 指定目录下。

Nginx配置
==========

- 需要注意，生产环境使用的静态文件都位于 ``staticfiles`` 目录，所以对于nginx配置，需要将 ``/static`` 目录映射成 ``staticfiles`` 所在目录

.. literalinclude:: nginx_gunicorn_django/onesre-core.conf
   :language: bash
   :linenos:
   :caption:

需要注意这里的配置::

   ...
       location /static/ {
           alias /home/admin/onesre/core/staticfiles/;
                     
       }

``location /static/`` 使用了 ``alias`` 指令，并且对应目录都是使用了 ``/`` 结束，这样才能完全一一对应。

当然，如果你配置::

   ...
       location /static/ {
           root /home/admin/onesre/core;
       }

也是可以的，但是这只能访问 ``/home/admin/onesre/core/static/`` 目录了，不能映射转换。就需要建立一个软链接，将 ``static`` 软链接到 ``staticfiles`` 。但这对通过 ``git clone`` 部署非常不方便。

参考
======

- `Managing static files (e.g. images, JavaScript, CSS) <https://docs.djangoproject.com/en/3.1/howto/static-files/>`_
- `Django Documentation: The staticfiles app <https://docs.djangoproject.com/en/3.1/ref/contrib/staticfiles/>`_
- `Django Static Files and Templates <https://learndjango.com/tutorials/django-static-files>`_
