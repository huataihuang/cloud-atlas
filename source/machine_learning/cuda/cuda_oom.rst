.. _cuda_oom:

====================================
``CUDA out of memory`` 排查和优化
====================================

在做大模型训练时，即使调度到 :ref:`nvidia_a100` 这样的超强硬件也是有显存限制的(80GB)，超大模型单卡依然会出现 ``CUDA out of memory`` ::

   torch.cuda.OutOfMemoryError: CUDA out of memory. Tried to allocate 80.00 MiB (GPU 0; 79.35 GiB total capacity; 76.70 GiB already allocated; 37.19 MiB free; 77.79 GiB reserved in total by PyTorch) If reserved memory is >> allocated memory try setting max_split_size_mb to avoid fragmentation.  See documentation for Memory Management and PYTORCH_CUDA_ALLOC_CONF
   main process return code: 1

GPT的答复
==========

先问问GPT 3.5给出的答案，至少有一个大致方向:

- 减小batch size。可以通过减小batch size来降低GPU内存的占用。
- 减小模型的复杂度。如果模型比较大，可以尝试减小模型的深度或宽度，来降低GPU内存的占用。
- 使用更多的GPU。如果有多个GPU可以使用，可以尝试在多个GPU上并行运行模型，从而减少每个GPU的内存占用。
- 使用FP16数据类型。使用FP16数据类型可以减少GPU内存的占用。
- 调整PyTorch的内存分配策略。可以通过设置max_split_size_mb参数来避免内存碎片，从而减少内存占用。

参考
=======

- `Solving the “RuntimeError: CUDA Out of memory” error <https://medium.com/@snk.nitin/how-to-solve-cuda-out-of-memory-error-850bb247cfb2>`_ 比较详细的解析
- `torch.cuda.OutOfMemoryError: CUDA out of memory. #19 <https://github.com/amazon-science/mm-cot/issues/19>`_ 降低batch参数方法
- `How to fix this strange error: "RuntimeError: CUDA error: out of memory" <https://stackoverflow.com/questions/54374935/how-to-fix-this-strange-error-runtimeerror-cuda-error-out-of-memory>`_ 可以尝试release cache
- `Solving "CUDA out of memory" Error <https://www.kaggle.com/getting-started/140636>`_
- `PyTorch FREQUENTLY ASKED QUESTIONS <https://pytorch.org/docs/stable/notes/faq.html>`_ 官方FAQ解释
