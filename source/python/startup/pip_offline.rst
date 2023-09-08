.. _pip_offline:

=====================
pip离线安装Python包
=====================

GFW真是墙内IT工作者的梦魇，倘若需要部署 :ref:`kubernetes` 这样大型基础设施，恐怕一半的精力都要浪费在翻墙、搬运上。即使像 :ref:`django_env_linux` 这样简单的日常开发环境，也不得不祭出"愚公移山"的苦力:

- 首先找一台网络通畅的主机，最好是同样的Python环境，例如，相同的 :ref:`virtualenv`

- 通过 ``pip downlaod`` 命令下载指定软件包(版本)，这里举例 ``Babel-2.12.1-py3-none-any.whl`` :

.. literalinclude:: pip_offline/pip_download
   :caption: ``pip download`` 可以下载指定版本python包

- 将下载好的 ``.whl`` python包复制到目标主机，然后就可以直接离线安装:

.. literalinclude:: pip_offline/pip_install_whl
   :caption: ``pip install`` 可以安装下载好的 ``.whl`` python包


参考
======

- `Installing Python packages (Offline mode) <https://www.ibm.com/docs/en/siffs/2.0.3?topic=python-installing-packages-offline-mode>`_
- `How do I install a Python package with a .whl file? <https://stackoverflow.com/questions/27885397/how-do-i-install-a-python-package-with-a-whl-file>`_
