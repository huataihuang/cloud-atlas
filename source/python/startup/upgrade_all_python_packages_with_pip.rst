.. _upgrade_all_python_packages_with_pip:

=============================
使用pip升级所有Python软件包
=============================

pip没有内建一条直接更新所有软件包的命令，因为pip建议你在每个项目上创建一个 :ref:`virtualenv` 来运行。为了能够在项目上使用最新的软件包，可以考虑升级软件包，并在 ``requirements.txt`` 文件中记录所有需要的软件包。

**绝对不要使用 sudo pip install 命令，也就是不要使用root身份安装Python软件包**

- 升级 ``pip`` :

.. literalinclude:: upgrade_all_python_packages_with_pip/pip_upgrade_pip
   :language: bash
   :caption: 使用pip升级pip

- 从 ``pip`` 22.3 开始，已经移除了 ``pip list --outdated`` 结合 ``--format=freeze`` 的组合参数，所以现在需要处理json输出，升级所有软件包的命令和之前不同，应该采用:

.. literalinclude:: upgrade_all_python_packages_with_pip/pip_upgrade_packages
   :language: bash
   :caption: 使用pip (22.3及以上版本) 升级Python软件包

- 如果是早于 pip 22.3 版本可以使用:

.. literalinclude:: upgrade_all_python_packages_with_pip/pip_upgrade_packages_before_pip_22.3
   :language: bash
   :caption: 使用pip (22.3之前版本) 升级Python软件包

.. note::

   使用 ``pip list --outdated`` 命令可以列出所有不是最新的软件包

- pip也可以将安装包的列表输出到一个requirements文件 ``requirements.txt`` 然后安装升级:

.. literalinclude:: upgrade_all_python_packages_with_pip/pip_upgrade_packages_by_requirements
   :language: bash
   :caption: 通过requirements.txt执行pip升级所有Python软件包

参考
=====

- `How to upgrade all Python packages with pip? <https://stackoverflow.com/questions/2720014/how-to-upgrade-all-python-packages-with-pip>`_
- `How To Update All Python Packages <https://www.activestate.com/resources/quick-reads/how-to-update-all-python-packages/>`_
