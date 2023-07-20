.. _intro_flask:

=================
Flask简介
=================

根据 JetBrains 的调查统计，在 :ref:`python` 的 `Web框架使用率(2021年和2022年) <https://www.jetbrains.com/lp/devecosystem-2022/python/#what-web-frameworks-libraries-do-you-use-in-addition-to-python->`_ ，Flask 和 :ref:`django` 始终是最受欢迎的框架(两者使用率几乎不分伯仲)。

Flask比Django更为轻量级，主要因为它是一个微框架，而不像Django那样作为Full stack那样功能全面。作为受到 `Sinatra Ruby framework <https://sinatrarb.com/>`_ 启发，Flask在提供了基础核心功能下，提供了清晰且性能卓越的WEB开发框架。

Flask依赖以下开源项目:

- `Werkzeug WSGI toolkit <http://werkzeug.pocoo.org/>`_
- `Jinja2 template <http://quintagroup.com/cms/python/jinja2>`_ 
- `MarkupSafe <https://palletsprojects.com/p/markupsafe/>`_ 随Jinja提供，渲染模版是避免注入攻击
- `ItsDangerous <https://palletsprojects.com/p/itsdangerous/>`_ 对数据进行安全签名确保完整性，用于保护flask的会话cookie
- `click command line interfaces <https://click.palletsprojects.com/>`_ 编写命令行应用程序的框架，提供了flask命令以及允许添加定制的管理命令
- `Blinker <https://blinker.readthedocs.io/>` 实现 ``Signals`` 功能(轻量级订阅通知)

Flask 并不原生支持数据库、Web表单、用户认证等高级功能，这些功能以及大多数Web程序所需的关键服务都以扩展的方式集成到核心包:

- 开发者可以任意选择符合项目需求的扩展，甚至自己开发(这和大型框架已经集成并且难以替换的方案不同)


参考
======

- `The Best Python Web Frameworks 2023 <https://dev.to/theme_selection/the-best-python-web-frameworks-d2d>`_
- `Flask vs Django: A Detailed Comparison of Python Web Frameworks <https://www.monocubed.com/blog/flask-vs-django/>`_
- `CherryPy Vs Flask – Which Is The Better Framework for Python? <https://www.monocubed.com/blog/cherrypy-vs-flask/>`_
- ``OReilly Flak Web Development 2nd Edition``
- `Flask docs: Installation <https://flask.palletsprojects.com/en/2.3.x/installation/>`_
