.. _flask_startup:

====================
flask快速起步
====================

最小化运行
=============

- 最小化的flask应用:

.. literalinclude:: flask_startup/hello.py
   :language: python
   :caption: 最小化的flask应用

- 运行:

.. literalinclude:: flask_startup/flask_hello_run
   :caption: 运行最小化的flask应用

简单说明:

  - ``route()`` 告知Flask是哪个URL触发这段程序的功能
  - 这里我使用了 ``hello.py`` ，所以采用 ``--app hello`` 来运行；如果程序名字是 ``app.py`` 或者 ``wsgi.py`` 就不需要 ``--app`` 参数

- 对外开放访问的运行:

.. literalinclude:: flask_startup/flask_hello_run_service
   :caption: 运行最小化的flask应用对外提供服务(绑定所有IP)

简单说明:

  - 默认flask运行只监听本地 ``127.0.0.1`` ，所以需要使用 ``--host=0.0.0.0`` 让flask监听在所有网络接口，也就是对外提供服务
  - 默认flask运行端口是 ``5000`` ，但是在 :ref:`macos` 上和 'AirPlay Receiver' 服务冲突，所以指定 ``--port=5001``

现在就可以访问主机的实际IP地址和端口来访问flask: http://192.168.6.1:5001

- 开启debug模式(方便调试):

.. literalinclude:: flask_startup/flask_hello_run_debug
   :caption: debug模式运行最小化的flask应用

HTML逃逸
=============

由于Flask默认响应是返回HTML，所以如果用户提供的值渲染时候需要防范输入特殊的HTML内容，例如，如果用户恶意嵌入一段 JS 代码，必须阻止渲染成HTML，否则就会导致在浏览器中执行恶意脚本。这种技术称为HTML逃逸(HTML Escaping)。

Flask 使用的 HTML 渲染模版 `Jinja2 template <http://quintagroup.com/cms/python/jinja2>`_ 已经内嵌了自动防范的功能，也就是说用户恶意注入JS会被自动阻止渲染。不过，这个 ``escape()`` 也可以人工添加:

.. literalinclude:: flask_startup/flask_escape.py
   :language: python
   :caption: 明确编写 ``escape()`` 防止恶意注入JS
   :emphasize-lines: 2,8

.. note::

   程序中 ``return f"Hello, {escape(name)}!"`` 中有一个 ``f`` 表示 ``f-string`` ，是Python 3.6以上版本共鞥，用于格式化字符串。也就是最后返回的值( ``escape()`` 处理后的值进行转义 )，最后返回的是 ``User xxx`` 

此时用户在浏览器中输入 http:://127.0.0.1:5001/<script>alert("bad")</script> 这样的注入，就会直接被拒绝渲染，页面提示::

   Not Found
   The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.

.. note::

   注意， `Jinja2 template <http://quintagroup.com/cms/python/jinja2>`_ 已经内嵌了自动防范的功能，上述代码片段不使用 ``escape()`` 也是有同样效果的

所以用户只能输入正常的名字 如 http:://127.0.0.1:5001/huatai

此时页面才能正常渲染::

   Hello,huatai!

路由(Routing)
================

Web应用会使用一些有意义的URLs让用户访问以及调用不同的函数返回页面，这种方式称为 ``route`` （路由)

.. literalinclude:: flask_startup/hello_route.py
   :language: python
   :caption: 路由访问

不同规则
==========

以下代码可以从url中获取需要的内容，根据不同路径以及关系分别返回 ``username / post_id / subpath`` ，你可以分别试试::

   http://http://127.0.0.1:5001/user/huatai
   http://http://127.0.0.1:5001/post/1
   http://http://127.0.0.1:5001/path/the_large_path/small_path

.. literalinclude:: flask_startup/variable_rules.py
   :language: python
   :caption: 根据用户访问路径来返回不同类型的数据

URL Building
================

构建特定函数的URL，使用 ``url_for()`` 函数，可以接受函数名作为第一个参数，以及任意数量的关键字参数。每个参数对应于URL规则的变量部分，未知的变量部分作为查询参数附加到URL中:

- URL反转功能 ``url_for()`` 构建URL，而不是硬编码到模版中:

  - 通常比硬编码URL更具描述性
  - URL构建透明地处理特殊字符转义
  - 生成的路径始终是绝对路径，避免浏览器中相对路径的意外行为

.. literalinclude:: flask_startup/url_for.py
   :language: python
   :caption: 动态构建URL

则可以访问以下路径::

   /
   /login
   /login?next=/
   /user/John%20Doe

HTTP metheods
=================

同样的URL，使用不同的HTTP methods会提供不同的功能，例如 ``login`` ，通常区分 ``GET`` 和 ``POST`` :

.. literalinclude:: flask_startup/http_methods.py
   :language: python
   :caption: 区分 ``GET`` 和 ``POST``

此外 flask 还提供了对于 ``get()`` 和 ``post()`` 方法的路由快捷方式，用于常用的HTTP method:

.. literalinclude:: flask_startup/http_methods_shortcut.py
   :language: python
   :caption: 区分 ``GET`` 和 ``POST`` 快捷方式

参考
=======

- `Flask docs: Quickstart <https://flask.palletsprojects.com/en/2.3.x/quickstart/>`_
