.. _llama_tunning_disable_numa:

===================================
关闭NUMA优化LLaMA推理速度
===================================

安装 :ref:`blfs_numactl` 后检查当前系统NUMA:

.. literalinclude:: llama_tunning_disable_numa/numactl_hardware
   :caption: 检查当前系统NUMA状态

可以看到输出中显示默认有2个NUMA节点:

.. literalinclude:: llama_tunning_disable_numa/numactl_hardware_output
   :caption: 检查当前系统NUMA状态可以看到有2个节点

可以看到每个NUMA节点使用了一半系统内存

由于推理需要访问整个内存空间，当出现跨节点访问内存时，NUMA会影响性能。在 `768GB内存，双AMD EPYC处理器本地化部署DeepSeek-R1的讨论(X) <https://x.com/carrigmat/status/1884244369907278106?s=46&t=5DsSie6D9vxgUafSFmo6EQ>`_ 特别提到了一个重要提示: **Go into the BIOS and set the number of NUMA groups to 0. This will ensure that every layer of the model is interleaved across all RAM chips, doubling our throughput. Don't forget!**

所以在BIOS中设置 ``NUMA=interleave`` ，然后重启系统后再次检查NUMA

.. literalinclude:: llama_tunning_disable_numa/numactl_hardware
   :caption: 检查当前系统NUMA状态

此时看到NUMA节点只有一个，也就是所有处理器访问相同的全部内存:

.. literalinclude:: llama_tunning_disable_numa/numactl_hardware_node0_output
   :caption: 检查当前系统NUMA状态可以看到有1个节点(node 0)

运行
=========

.. literalinclude:: ../../../deepseek/deploy_deepseek-r1_locally_cpu_arch_lfs/run_model
   :caption: 运行
   :emphasize-lines: 3

运行结果:

.. literalinclude:: llama_tunning_disable_numa/tokens
   :caption: 关闭NUMA之后推理速度达到 ``1.063 tokens/s``
   :emphasize-lines: 10

.. literalinclude:: llama_tunning_disable_numa/tokens_1
   :caption: 关闭NUMA之后推理速度达到 ``1.039 tokens/s``
   :emphasize-lines: 10
   
可以看到推理速度达到 ``1.063 tokens/s`` ，也就是比没有关闭NUMA之前的 ``0.66 tokens/s`` 提高了 ``61%`` ，性能提升还是比较明显的，虽然每秒1个token的推理速度依然实用性不强。

.. note::

   :ref:`intel_turbo_boost_pstate` 可以在Turbo Boost模式下达到 3.1G Hz，比默认的 2.5G Hz快 ``24%`` 。也就是说，理论上推理速度可以达到 ``1.32 tokens/s``
