.. _django_env_macos:

=======================
Django开发环境(macOS)
=======================

作为Python Web框架，Django需要Python支持才能运行。目前Python 2.x已经终止开发，如果你的项目刚刚开始，请从Python 3开始(Python 3不兼容Python 2)。请首先安装Python 3。

建议从 `Python官网下载 <https://www.python.org/downloads/>`_ 最新版本，或者从发行版安装。

对于macOS系统默认安装了Python 2.7为了兼容遗留代码，最新的Catalina(10.15.x)也安装了Python 3，不过需要注意执行命令是 ``python3`` 。但是需要注意的是，即使macOS Big Sur 11.1内建的Python 3也不支持GUI的 :ref:`python_tkinter` ，所以建议从官方网站安装最新版本(包含了完整的库支持)。

也可以通过 `Homebrew <http://brew.sh/>`_ 安装Python3::

   xcode-select --install
   ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

   echo "export PATH=/usr/local/bin:$PATH" >> ~/.bash_profile

   brew install python3

安装Virtualenv
================

为了方便使用Python 3，建议通过virtualenv来构建Python运行环境::

   sudo pip3 install --upgrade pip
   sudo pip3 install virtualenv
   # 在Catalina上，使用默认Python3
   #/usr/local/bin/virtualenv venv3

   # 在早期Mac OS X 10.9(Mavericks)，使用Python官方Python3
   virtualenv venv3

根据提示，将脚本路径 ``/Users/huataihuang/Library/Python/3.7/bin`` 加入环境变量 ``$PATH`` ::

   export PATH=$PATH:$HOME/bin:/usr/local/mysql/bin:/Users/huataihuang/Library/Python/3.7/bin

然后激活环境变量::

   # Catalina系统使用zsh，如果是早期版本，使用 ~/.bash_profile
   . ~/.zshrc

再激活Python 3的virutalenv::

   . venv3/bin/activate

此时激活了virtualenv环境，则执行 ``python`` 指令显示的运行环境就是Python 3。

- 安装我的常用开发依赖库：即编辑一个 ``requirements.txt`` 配置（通常可以在Django项目的目录下存放），这里和 :ref:`docker_compose_django` 共用 ``requirements.tst`` :

.. literalinclude:: ../../docker/applications/requirements.txt
   :language: bash
   :linenos:

然后执行以下命令安装::

   pip install -r requirements.txt

安装Django
===========

在Python 3的virtualenv环境中，我们可以通过 ``pip`` (也是 ``pip3`` ) 或者 ``pip3`` 命令来安装django::

   pip install Django

.. note::

   以上默认安装的是office release，适合大多数用户。

   此外，还可以安装操作系统发行版的Django。(根据发行版不同使用对应的包管理工具安装)

   或者安装最新的开发版本::

      git clone https://github.com/django/django.git
      python -m pip install -e django/

安装以后可以验证所安装的Django版本::

   >>> import django
   >>> print(django.get_version())
   3.0.2

安装Selenium(硒)
==================

测试驱动开发模式下，我们安装Selenium来作为浏览器自动化工具::

   pip install selenium

测试功能
=========

- ``functional_tests.py`` ::

   from selenium import webdriver
   browser = webdriver.Firefox()
   browser.get('http://localhost:8000')
   assert 'Django' in browser.title

- 执行::

   python functional_tests.py

注意，上述执行的功能测试调用了 ``webdriver.Firefox()`` 驱动，所以需要系统中已经安装了Firefox。但是，即使安装了Firefox，依然会报错::

   FileNotFoundError: [Errno 2] No such file or directory: 'geckodriver': 'geckodriver'
   ...
   selenium.common.exceptions.WebDriverException: Message: 'geckodriver' executable needs to be in PATH.

这是因为Selenium需要一个web驱动。所谓的web驱动是一个和web浏览器交互的软件包，可以和本地浏览器或者远程的web服务器通过一种通用协议交互。以下是三种主流的浏览器的web驱动:

- chrome: https://sites.google.com/a/chromium.org/chromedriver/downloads
- firefox: https://github.com/mozilla/geckodriver/releases
- safari: https://webkit.org/blog/6900/webdriver-support-in-safari-10/

在案例中我们使用了firefox的geckodriver，所以下载对应驱动，存放到 ``$HOME/bin`` 目录下，然后在个人profile中添加::

   export PATH=$PATH:$HOME/bin

加载环境变量之后，再次在virtualenv中执行上述 ``python functional_tests.py`` 就会打开Firefox浏览器，访问 http://localhost:8000 

OK，现在我们已经就绪了程序开发和运行环境，我们将准备Django的Demo以及一些开发必要工作。

参考
=====

- `django quick install guide <https://docs.djangoproject.com/en/3.0/intro/install/>`_
