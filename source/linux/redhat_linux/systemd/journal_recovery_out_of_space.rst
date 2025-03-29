.. _journal_recovery_out_of_space:

==================================
磁盘空间打爆以后恢复journal日志
==================================

遇到一个线上问题，根目录磁盘空间被打爆以后， ``journal`` 日志文件损坏了:

- 检查磁盘硬件应该是正常的，因为能够独立删除 ``/var/log`` 目录下文件，并且也能够写文件
- 但是执行任何 ``journalctl`` 命令都会报错 ``Error was encountered while opening journal files: Input/output error`` :

.. literalinclude:: journal_recovery_out_of_space/journal_file_error
   :caption: 无法操作journal日志文件，始终报错

已经手工清理了 ``/var/log`` 目录下 的一些 sar 文件，也就是空出了根目录大约几百兆

- 尝试校验journal日志文件

.. literalinclude:: journal_recovery_out_of_space/journalctl_verify
   :caption: DEBUG模式校验journal日志文件 

但是还是不行

- 实在找不出解决的方法，似乎没有 ``repair`` 命令参数，所以最后还是清理掉所有历史日志重新开始:

.. literalinclude:: journal_recovery_out_of_space/journalctl_repair
   :caption: 无法修复jouranl日志文件，所以清理掉所有日志重新开始

参考
=======

- `Corrupted user journal files #24150 <https://github.com/systemd/systemd/issues/24150>`_
- `Systemd journal corruption on Fedora <https://blog.paranoidpenguin.net/2021/02/systemd-journal-corruption-on-fedora/>`_
