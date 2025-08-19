.. _vulkan:

=================
Vulkan
=================

``Vulkan`` 是一种底层、低开销( ``low-overhead`` )的跨平台API和3D图形和计算的开放标准。Vulkan目标是解决OpenGL的缺点，以便开发人员更好地控制GPU。Vulkan支持多种GPU、CPU和操作系统，并且还能够和现代的多喝CPU配合使用。

Vulkan面向高级实时3D图形应用程序，例如视频游戏、交互媒体以及高度并行化的计算。和旧版的OpenGL和Direct3D 11 API相比较，Vulkan趋向于通过比旧版API提供更底层的API来实现提供更高的性能好额更高效的CPU和GPU使用率，Vulkan API更接近现代GPU的工作方式。

Vulkan源自AMD Mantle API组件(AMD将Mantle API捐赠给Khronos)，由非盈利组织Khronos Group于2015年GDC上发布。

Vulkan和 Apple 的Metal API 和 Microsoft的 Direct3D 12相当，除了较低的CPU使用率外，还能够让开发人员更好地在多个CPU核心上分配负载。

Vulkan的优点:

- 跨平台
- 低CPU使用率
- 多线程友好的设计
- 预编译着色器(pre-compiled shaders)

:ref:`intel_uhd_graphics_630`
==============================

:ref:`intel_uhd_graphics_630` 虽然性能有限，并且也不支持 :ref:`llama` 的 `llama.cpp for SYCL <https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/SYCL.md>`_ (需要Intel 11代CPU内置GPU)，但是还是支持 Vulkan 1.3。理论上来说， :ref:`install_llama.cpp_vulkan` 可以采用非常廉价的 :ref:`xeon_e-2274g` 内置 :ref:`intel_uhd_graphics_630` 来完成llm模型推理。是的，性能可能不好，但是借助相对巨大的内存，或许可以加载较大规模的LLM模型。

参考
======

- `Wikipedia: Vulkan <https://en.wikipedia.org/wiki/Vulkan>`_
- `Supported APIs for Intel® Graphics <https://www.intel.com/content/www/us/en/support/articles/000005524/graphics.html>`_
