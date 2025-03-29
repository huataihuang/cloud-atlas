.. _vim_gz:

================
vim对.gz文件处理
================

遇到一个奇怪的问题，折腾了一下，感觉很有意思:

我在撰写 :ref:`sphinx_doc` 时， ``make html`` 报错:

.. literalinclude:: vim_gz/sphinx_make_html
   :caption: sphinx执行 ``make html`` 报错

奇怪，我使用 ``vi zcat_config.gz`` 这个文件的内容，显示的完全正常:

.. literalinclude:: ../../gentoo_linux/gentoo_ia32/zcat_config_gz

但是，一旦用 ``cat zcat_config.gz`` 就看出异常了，完全是乱码

原因:

- vim 可以直接编辑 ``.gz`` 压缩文件，实际上就是先解压，然后编辑文本
- 如果用vim编辑一个空文件，但是这个空文件名有后缀 ``.gz`` ，则 vim 会默认这个有 ``.gz`` 后缀名的文件就是一个压缩文件，就会自动生成一个压缩文件(内部包含文本)
- 此时这个文件虽然用vim编辑没有问题，以为是一个纯文本，但实际上已经被压缩了，此时使用 ``cat`` 或 ``file`` 检查，就会看到乱码
- 类似系统内核 ``/proc/config.gz`` 文件，都是需要使用 ``zcat`` 来检查的，也可以直接使用 ``vim`` 查看，总之，非常方便，但是也要注意这个默认对 ``.gz`` 后缀名的文件处理特点
