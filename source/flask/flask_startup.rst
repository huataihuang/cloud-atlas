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

此时用户在浏览器中输入 http:://127.0.0.1:5000/<script>alert("bad")</script> 这样的注入，就会直接被拒绝渲染，页面提示::

   Not Found
   The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.

.. note::

   注意， `Jinja2 template <http://quintagroup.com/cms/python/jinja2>`_ 已经内嵌了自动防范的功能，上述代码片段不使用 ``escape()`` 也是有同样效果的

所以用户只能输入正常的名字 如 http:://127.0.0.1:5000/huatai

此时页面才能正常渲染::

   Hello,huatai!

参考
=======

- `Flask docs: Quickstart <https://flask.palletsprojects.com/en/2.3.x/quickstart/>`_
