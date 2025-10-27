.. _think_apple_silicon_machine_learning:

=====================================
Apple Silicon机器学习的思考
=====================================

2024年10月底 :ref:`mac_mini_2024` 横空出世，Apple Silicon M4处理器带来的最具性价比苹果设备，在国补和教育优惠下能够下探到4000以下售价。时光飞逝，转眼在我开始写下这篇文章时(2025年10月27日)，苹果已经在上周推出了基于M5的多款设备，虽然还没有轮到经济型的Mac mini，但是预计也就在这几周时间了。

硬件
======

凭借苹果成熟的制造技术和产品质量，Mac mini实际上远超个人自己攒机所能获得的计算性能:

- 对比我采购了大量 :ref:`raspberry_pi` 设备及周边，同样的4k投资无法获得低功耗稳定强劲的计算和AI性能
- 对比我组合二手 :ref:`tesla_p10` 以及Intel台式机，实际上4k获得的主机工艺质量也无法和苹果精密设备媲美

此外，如火如荼的大语言模型技术(机器学习)发展，使得我更加考虑是否基于Apple Silicon架构来构建机器学习平台:

- Apple Silicon的统一内存架构(Unified Memory Architecture, UMA)天然具有高带宽特性，能够加速AI性能(当前统一内存架构已经成为主流GPU提升性能的利器，AMD和NVIDIA都有类似产品架构)
- 2025年10月推出的M5 Apple Silicon增强的神经网络引擎和全新的GPU架构，在AI相关的性能比上一代M4快3.5倍:

  - 神经网络引擎: 比M4快29%
  - 统一内存带宽: 153 GB/s，比M4 (120GB/s) 快27.5%
  - SSD性能: 比M4快2倍
  - 比M4增加了新的神经加速器

从苹果发布周期来看，很快会发布基于M5处理器的经济型Mac mini，如果售价和去年M4机型一致，那么性价比也是非常高的。特别是在AI方面，可能比M4更值得入手。

M5处理器特性
------------------

- 每个GPU核心都配备了专用的神经加速器

  - AI计算负载分担：将部分AI计算任务从传统的神经网络引擎（NPU）分流到GPU，可以显著提升AI工作流的整体效率
  - 更高的并行计算能力：通过在GPU核心中加入神经加速器，加速原本由CPU或NPU处理的AI任

- 神经网络引擎（NPU）: M5和M4一样是16核NPU，但效率上有所增强，能以更低的功耗提供更强的AI性能

- 统一内存带宽: M5内存带宽从M4的120GB/s提升至153GB/s，可加快AI训练和推理过程中的数据传输速度

.. note::

   不差钱的话，其实入手 M3 Ultra 的 Mac Studio 更好: 苹果当前售卖的最高端 M3 Ultra Mac Studio 可以配置512GB统一内存，意味着可以直接加载  :ref:`deepseek` ``deepseek-r1:671b`` 4位量化模型 (404GB)

   顶配16GB SSD存储，只需要10w RMB

集群
======

网络
---------

单台Mac mini，特别是入门款，内存非常有限，只有16GB。实际上有部分内存必须保留给操作系统使用，估计能够用于AI负载的只有12GB。考虑到我的经费有限，最多也就购买丐版Mac mini来跑大模型。那么有没有办法来组建Apple Silicon集群呢?

组网方案:

- 高性能以太网: 需要10Gb以太网接口，但综合考虑我觉得不经济

  - 对于Mac mini不太现实: 万兆网口需要加800元，有这个经费不如直接加内存更好
  - 雷雳口实际上能够用第三方万兆网卡，但是又多了一笔网卡投资
  - 另外需要配置一台万兆交换机

- 雷雳（Thunderbolt）网络: 利用Mac mini自带雷雳5接口，能够实现80Gb/s双向带宽(我觉得这是个人最经济的方案)

  - 适合小型组网(反正我也买不起很多Mac mini)
  - 超高带宽: 雷雳4提供40Gb/s，雷雳5则可提供最高80Gb/s的双向带宽
  - 低延迟：设备间直接连接，通信延迟极低

- 专用互联技术（Infiniband）: 这个"贵族"方案就不考虑了，除了大厂，个人没法负担

综合考虑，我准备采用 ``雷雳（Thunderbolt）网络`` 来构建小型Mac mini集群网络

软件
-------

- 操作系统: 依然使用macOS

早期我曾经想过是否需要将Mac mini的操作系统替换成 :ref:`asahi_linux` 来运行标准的基于Linux的 :ref:`vllm` ，但是目前看来实现可能性不大: Linux无法驱动Apple Silicon专有的GPU和NPU，导致只能使用CPU进行机器学习。

虽然Apple Silicon的CPU性能也很强，但是这样的方案是买椟还珠，相当于白白浪费了苹果核心的硬件优势

- 分布式框架

苹果的MLX框架和Ray等工具可以支持在macOS上实现分布式LLM，能够实现学习、实验或中等规模的本地推理。当然，这无法和NVIDIA架构下只有Linux才有的最佳工具vLLM相比，但是能够充分发挥GPU和NPU的性能，也是学习另一种机器学习架构的好机会。

.. note::

   macOS平台没有 :ref:`vllm` 工具，但是有一些能够充分利用Apple Silicon实现高性能本地LLM推理的工具，结合一些部署优化可能可以实现分布式推理：

   - :ref:`ollama` 底层使用的 :ref:`llama.cpp` 能够将模型转为GGUF格式，利用CPU和GPU混合推理，在Apple Silicon上性能优异。由于 ``llama.cpp`` 社区正在开发分布式推理功能(基于gRPC的RPC协议)，通过一个"leader"节点协调多个"worker"节点实现模型分片，所以通过一定配置可能可以实现分布式推理。(Ollama的社区正在探索利用llama.cpp的分布式推理功能)
   - Ollama主要针对本地使用，结合K2/olol等项目可以实现Ollama集群负载均衡和透明扩展(待研究实践)
   - 苹果官方的MLX框架原生支持分布式通讯，是实现高效集群化的最佳选择(分布式通信API, 模型并行, 不过需要手工配置集群，通过SSH和网络共享，并利用Python脚本启动分布式任务)
   - PyTorch 使用MPS后端(单机多进程，有限支持分布式)，需要使用PyTorch的分布式数据并行(DDP)并结合gloo后端(CPU通信，会显著降低性能)

   总之，上述框架部署需要进一步研究和实践

思路二是 :strike:`安装双操作系统切换` (感觉可能会浪费大量时间折腾)，在使用 :ref:`vllm` 时切换到 :ref:`asahi_linux` ，采用CPU模式模拟集群运算。

思路三是在 macOS 上运行 :ref:`apple_container` ，当前苹果官方推出的原厂解决方案能呕充分发挥硬件性能来运行Linux容器，在小规模模拟下可能是一个解决思路。由于即使使用裸Linux也无法使用GPU和NPU，实际上container模式运行Linux来部署vLLM ，采用CPU模式运行，应该和裸金属Linux没有差别。

总之， "体法双修" 是飞升之道

- PyTorch

PyTorch 1.12及更高版本包含对苹果MPS支持，目前已经实现将计算任务放到GPU上运行。未来PyTorch应该会扩展支持神经引擎(ANE)，性能会进一步提升。

此外，苹果还发布了为Apple Silicon优化的机器学习框架MLX，某些操作比PyTorch的MPS后端更快，后续要研究PyTorch和MLX结合使用。

随便想想
==========

作为苹果最具性价比的Mac mini，叠加现在"国补"，估计M5处理器的版本可能在4k左右(如果能有更低价格更好)，用于组建虚拟化集群、容器化 :ref:`kubernetes` 以及机器学习平台，极具性价比。

如果经济能力允许，我会购买至少2台来组建集群学习集群...待续

参考
=====

- `M4 Mac minis in a computing cluster is incredibly cool, but not hugely effective <https://appleinsider.com/articles/24/11/25/m4-mac-minis-in-a-computing-cluster-is-an-incredibly-cool-project-but-not-hugely-effective>`_
- `Installing vLLM on macOS: A Step-by-Step Guide <https://medium.com/@rohitkhatana/installing-vllm-on-macos-a-step-by-step-guide-bbbf673461af>`_
- `How to Run vLLM on Apple M4 Mac Mini <https://aipmbriefs.substack.com/p/how-to-run-vllm-on-apple-m4-mac-mini>`_
