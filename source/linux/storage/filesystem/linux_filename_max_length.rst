.. _linux_filename_max_length:

=========================
Linux文件名最大长度
=========================

在生产环境中，总会遇到奇奇怪怪的问题。今天，一个异常长度的文件名导致脚本执行错误，引起我的好奇心，所以记录下Linux文件名最大长度。简单(简化)来说总结如下：

- 文件名的最大长度通常是 ``255`` 个字节(字符)(大多数操作系统都是这样)
- 文件名加路径组合起来最大长度是 ``4096`` 个字节
- 当使用归档和查询操作(我理解为 ``tar`` )最大文件名加路径组合是 ``1024`` 个字节

如果你有疑问，可以参考 `wikipedia: Comparison_of_file_systems#Limits <https://en.wikipedia.org/wiki/Comparison_of_file_systems#Limits>`_

参考
======

- `Filename length limits on linux? <https://serverfault.com/questions/9546/filename-length-limits-on-linux>`_
- `File specification syntax <https://www.ibm.com/docs/en/spectrum-protect/8.1.9?topic=parameters-file-specification-syntax>`_
- `Limit on File Name Length in Bash <https://www.baeldung.com/linux/bash-filename-limit>`_
