.. _pip:

======================
pip (Python包管理器)
======================

pip(对于Python 3则别名为 pip3)是一个使用Python编写的Python软件包管理器。Python软件基金会建议使用pip来安装Python应用以及依赖。Pip连接到在线的公共Python包仓库( `Python Package Index <https://pypi.org/>`_ ，即 ``PyPi`` )来实现软件包的安装和管理。也能够配置成连接本地或远程的软件包仓库，提供实现Python Enhancement Proposal (PEP) 503。

pip自身升级
============

在构建 :ref:`virtualenv` 之后运行pip，通常会提示pip有最新版本可以升级，此时可以升级pip:

.. literalinclude:: pip/pip_upgrade_pip
   :caption: pip升级pip

如果pip版本过高也可降级:

.. literalinclude:: pip/pip_downgrade_pip
   :caption: pip降级pip

pip安装指定版本python包
=========================

一些软件开发采用了旧版本Python软件包环境，所以需要指定安装版本:

.. literalinclude:: pip/pip_install_specific_package
   :caption: pip安装指定版本python包

- 此外， ``pip`` 还提供了指定版本范围的安装方法:

.. literalinclude:: pip/pip_install_specific_range_package
   :caption: pip安装指定版本范围python包

降级(已经安装过软件包)
-------------------------------

- 如果安装了高版本软件包想要降级，采用的方法其实还是上文安装指定Python包的方法，但是需要使用 ``-I`` ( ``--ignore-installed`` ) 参数表示忽略已经安装版本，或者使用强制参数 ``--force-reinstall`` :

.. literalinclude:: pip/pip_install_specific_package_force
   :caption: pip降级指定python包(强制安装)

案例:

我在 :ref:`` 遇到旧项目无法兼容Django 4.x ，所以强制Downgrade到 Django 3.2.21 (由于生产环境不通外网，采用 :ref:`pip_offline` )

.. literalinclude:: pip/pip_download
   :caption: 离线下载 Django-3.2.21

.. literalinclude:: pip/pip_install_specific_package_force_offline
   :caption: 离线方式强制安装指定版本(Downgrade)

可以看到实际上是先卸载旧的高版本(相同版本也是卸载)，然后再重新安装指定版本(降级):

.. literalinclude:: pip/pip_install_specific_package_force_offline_output
   :caption: 离线方式强制安装指定版本(Downgrade)输出信息

检查安装的软件包(版本)
=========================

- 执行 ``pip list`` 可以看到已经安装的所有Python包:

.. literalinclude:: pip/pip_list
   :caption: ``pip list`` 检查所有软件包

输出显示:

.. literalinclude:: pip/pip_list_output
   :caption: ``pip list`` 检查所有软件包输出案例

- 使用 ``pip show`` 可以查看安装包的相信信息:

.. literalinclude:: pip/pip_show
   :caption: ``pip show`` 检查指定软件包详细信息

输出案例:

.. literalinclude:: pip/pip_show_output
   :caption: ``pip show`` 检查Django的包信息

执行 ``setup.py`` 安装
=========================

一些Python的软件包需要在系统中编译安装，例如 ``mysqlclient`` ，下载下来是tar包 ``mysqlclient-2.2.0.tar.gz`` ，解压缩以后，在包的根目录下有一个文件 ``setup.py`` 。那么该怎么安装呢? 😁

.. literalinclude:: pip/pip_setup.py
   :caption: ``setup.py`` 方式安装Python包

简单到令人吃惊... **注意** 不是直接运行 ``setup.py`` ( 在Python官方文档有关于 `Writing the Setup Script <https://docs.python.org/3/distutils/setupscript.html>`_ 详细说明 )

参考
======

- `Pip Upgrade – Install/Uninstall/Downgrade/Update Pip Packages: A Python Guide <https://cloudzy.com/blog/pip-upgrade/>`_
- `Installing specific package version with pip <https://stackoverflow.com/questions/5226311/installing-specific-package-version-with-pip>`_
- `wikipedia: pip (package manager) <https://en.wikipedia.org/wiki/Pip_(package_manager)>`_
- `How do I check the versions of Python modules? <https://stackoverflow.com/questions/20180543/how-do-i-check-the-versions-of-python-modules>`_
- `What is setup.py? <https://stackoverflow.com/questions/1471994/what-is-setup-py>`_
