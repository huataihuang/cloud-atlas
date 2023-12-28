.. _install_flask:

====================
安装Flask
====================

flask支持Python 3.8以及更新版本

:ref:`virtualenv`
=====================

- 安装和初始化 :ref:`virtualenv` :

.. literalinclude:: ../../startup/virtualenv/apt_install_pip3_venv
   :language: bash
   :caption: 在 :ref:`ubuntu_linux` 22.04 LTS 安装 ``pip3`` 以及 ``venv``

.. literalinclude:: ../../startup/virtualenv/venv
   :language: bash
   :caption: venv初始化

.. literalinclude:: ../../startup/virtualenv/venv_active
   :language: bash
   :caption: 激活venv

然后在 :ref:`virtualenv` 就可以继续使用 ``pip`` 安装Flask了

安装
=======

- 使用pip安装flask:

.. literalinclude:: install_flask/pip_install_flask
   :caption: 使用pip安装flask

参考
=====

- `Flask docs: Installation <https://flask.palletsprojects.com/en/2.3.x/installation/>`_
- ``OReilly Flak Web Development 2nd Edition``
