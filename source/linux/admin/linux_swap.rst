.. _linux_swap:

==============
Linux swap
==============

:ref:`gentoo_chromium` 编译对内存要求很高，超出了我的笔记本 16GB，会导致 :ref:`linux_oom` ，所以设置swap:

.. literalinclude:: linux_swap/swapfile
   :caption: 设置8G swap文件

参考
=====

- `arch linux: swap <https://wiki.archlinux.org/title/swap>`_
