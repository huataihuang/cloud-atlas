.. _ruby_in_browser:

======================
在浏览器中运行Ruby
======================

:ref:`ruby_quickstart` 案例是终端运行ruby脚本，但是ruby的灵活性和表现力导致David Heinemeier Hansson(通常简称为"DHH")开发了 :ref:`rails` 框架在浏览器中运行ruby。此外，简单的ruby程序，也可以通过 `Sinatra <https://sinatrarb.com>`_ 微框架来完成，这里的案例我主要是实践一遍了解流程概况(从github推送到heroku)。

安装微框架
============

- 创建gem安装配置，去除文档安装部分:

.. literalinclude:: ruby_in_browser/gemrc
   :caption: 创建 ``~/.gemrc``

- 安装需要的 gem

.. literalinclude:: ruby_in_browser/gem_install
   :caption: 安装需要的gems

hello_app.rb
==============

- ``hello_app.rb`` 包含最简单的如下内容

.. literalinclude:: ruby_in_browser/hello_app.rb
   :language: ruby
   :caption: 最简单的hello

- 然后执行运行命令

.. literalinclude:: ruby_in_browser/run
   :language: bash
   :caption: 运行

终端输出信息:

.. literalinclude:: ruby_in_browser/run_output
   :caption: 运行输出信息
   :emphasize-lines: 9

此时访问本地回环地址 4567 端口，就可以看到浏览器输出内容 ``hello, world!``

部署到Heroku
===============

.. note::

   在 `heroku官网 <https://www.heroku.com/home>`_ 注册账号，并且提交了支付方式(似乎不能使用国内信用卡)之后才能创建应用

.. warning::

   我没有搞定heroku的信用卡支付功能，所以实际上没有完成这步部署。不过，我整理记录了一下，理解了这个部署:

   - heroku 会根据你本地仓库的git配置来完成heroku的应用创建
   - 完成应用创建后，heroku就会和你git仓库绑定，自动从git仓库下载源代码，并完成持续部署(只要仓库变动就自动完成部署)

   我自己也能够部署 :ref:`gitlab` 来完成这个流程，自己部署更有乐趣

- 首先安装 :ref:`heroku_cli`

- 执行heroku应用创建:

.. literalinclude:: ruby_in_browser/heroku_create
   :language: bash
   :caption: 创建heroku应用

- 在项目目录下创建一个 ``config.ru`` 配置，包含以下内容:

.. literalinclude:: ruby_in_browser/config.ru
   :caption: heroku 配置 config.ru

- 配置一个Gemfile列出需要的gem组件:

.. literalinclude:: ruby_in_browser/Gemfile
   :caption: 创建Genfile列出需要的组件，类似于Python的 requirements.txt

- 现在需要使用 ``bundler`` 打包然后推送:

.. literalinclude:: ruby_in_browser/bundler
   :caption: 使用 ``bundler`` 打包并推送仓库

参考
=======

- `Learn Enough Ruby to Be Dangerous <https://www.learnenough.com/ruby>`_
