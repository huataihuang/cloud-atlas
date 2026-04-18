.. _vim_hex_edit:

=======================
vim编辑hex文件
=======================

我在 :ref:`dell_t5820_gpu` 想尝试是否能够通过修订VBIOS的SSID，也就是VBIOS中标记GPU型号的修改来扰过 :ref:`dell_t5820` 对GPU卡的限制(如果它确实只允许使用workstation graphics的话)

这就需要能够直接编辑hex十六进制文件，如果使用HexEdit这种工具虽然方便，但是在Linux平台，显然 ``vim`` 更为普遍。Linux中有一个系统工具 ``xxd`` 可以处理二进制文件，vim可以通过调用 ``xxd`` 来实现 :ref:`amd_mi50_change_vbios_bar_size` 这样的固件修改。

.. note::

   修订SSID最好使用 Red BIOS Editor (RBE) 或者在 GOPUpd 处理完后再用 hexedit 修改

- 首先在终端用vim打开ROM文件:

.. literalinclude:: vim_hex_edit/vim_binary
   :caption: 以 ``-b`` 参数(Binary模式)打开ROM二进制文件

.. note::

   ``-b`` 参数(Binarymoshi)非常重要，可以防止vim尝试猜测字符编码或者在文件末尾自动添加换行符，避免破坏固件结构

- 转换成十六进制可视化:

进入vim后，输入如下命令

.. literalinclude:: vim_hex_edit/xxd
   :caption: 调用xxd转换标准十六进制

此时文件会由乱码转换成标准的十六进制网格，左侧是偏移量(Offset)，中间是十六进制数据，右侧是ASCII预览

- 编辑文件，建议使用 ``r`` 替换单个字符， **不要使用** ``i`` 插入模式以免文件长度偏移破坏校验

- **转换回二进制并保存**

这一步非常关键，如果没有转换回去情况下保存，文件会损坏

.. literalinclude:: vim_hex_edit/xxd-r
   :caption: 转换回二进制并保存

这里 ``-r`` 表示 reverse，将十六进制文本重新压回原始二进制流

.. warning::

   当使用vim调用xxd修改二进制的ROM文件，一定要确保修改前后ROM大小不变，谨防因为不小心按了回车导致字节数增加。
