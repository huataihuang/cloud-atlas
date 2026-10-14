.. _machine_learning_learning_roadmap:

========================
机器学习的学习线路图
========================

.. note::

   我感觉机器学习的学习线路图可能有很多条，网上也会看到有不同人的推荐。不过，我觉得最重要的是扎实的学习和实践，有可能条条大路通罗马。

   本文仅仅是一个综合gemini的建议，但是真正的实践笔记我准备从头开始通过 :ref:`quarto` 来构建，如果我能够完成这个学习过程，那么我的笔记才是有用的，否则单纯摘抄意义不大。

.. warning::

   本文会随着实践进行更新，最初的Roadmap框架来自gemini建议，但是gemini的幻觉以及知识范围可能在对话中可能没有及时更新，所以我会在后续实践中逐步修订本文。

``第一阶段：兴趣引导与快速落地（入门期）``

.. _practical_deep_learning_for_coders:

Practical Deep Learning for Coders
====================================

`fast.ai <https://www.fast.ai/>`_ 是一个 **非营利性** 的研究实验室与教育机构(Non-profit Research Lab / Institute)，由Jeremy Howard（前 Kaggle 首席科学家）和 Rachel Thomas 博士（数据科学家、旧金山大学数据研究所创始主任）于 2016 年联合创立。

fast.ai 的核心宗旨是 “Making Neural Nets Uncool Again” (让深度学习不再高不可攀 / 深度学习大众化)，即打破AI/深度学习领域被大型科技巨头（Google、Meta 等）和顶级名校学术圈的严重垄断:

- 自顶向下（Top-Down）教育：主张“先运行代码看到成果，再去探索底层原理”，让没有 PhD 学位的普通程序员也能在几小时内训练出 SOTA（最前沿）级别的 AI 模型。
- 高层抽象与工程效率：通过编写开源工具，将复杂的 PyTorch 最佳实践（如最佳学习率选择器 lr_find()、混合精度训练、数据预处理等）封装成几行代码。
- 降低算力成本：研究如何在消费级 GPU（如单张 RTX 显卡）甚至轻量级设备上高效训练和微调模型。

课程生态(Education):

- Part 1: `Practical Deep Learning for Coders <https://course.fast.ai/Lessons/lesson1.html>`_ ：自顶向下应用，教你如何快速构建与部署模型
- Part 2: `Deep Learning Foundations to Stable Diffusion <https://course.fast.ai/Lessons/part2.html>`_ : 自底向上重构，从零手写矩阵乘法、反向传播与类似 fastai/PyTorch 的底层框架
- `How to Solve It With Code <https://solve.it.com/>`_ 一门编程思维与基础工具课程，重点并不是深度学习算法，而是教新手或跨界开发者如何利用现代工具（如 Python、Jupyter Notebook、终端以及 AI 编程助手）去高效、系统地“用代码解决实际问题”，是进入深度学习前的工程与代码习惯铺垫。

开源工具链(Developer Tools):

- ``fastai`` for PyTorch: 建立在 PyTorch 之上的高阶深度学习库。它既有“极简 API”（一行代码完成数据载入与训练），又保持了极其清晰的分层架构（High-level API ➔ Mid-level ➔ Low-level），允许进阶开发者随时覆盖底层细节。
- :ref:`nbdev` : 允许开发者完全在 Jupyter Notebooks 里编写 Python 库、自动化生成单元测试、导出 PyPI 包以及生成官方文档。fastai 库本身就是完全用 ``nbdev`` 在 ``Notebook`` 里写出来的！

.. _neural_networks_zero_to_hero:

Neural Networks: Zero to Hero
==============================

`Neural Networks: Zero to Hero (playlist) <https://www.youtube.com/watch?v=VMj-3S1tku0&list=PLAqhIrjkxbuWI23v9cThsA9GvCAUhRvKZ>`_ 是前 Tesla AI 总监、OpenAI 联合创始人 Andrej Karpathy 亲自主讲。

课程自底向上（Bottom-up），从零用纯 Python 手写 ``micrograd`` (自动求导引擎) , ``makemore`` (语言模型)，逐步实现 ``nanoGPT`` 。通过逐行调试 Python 代码，可以彻底搞懂 Backpropagation（反向传播）、Cross-Entropy Loss、以及 Self-Attention 矩阵乘法的每一维 Shape 是怎么变化的。

`GitHub: Neural Networks: Zero to Hero <https://github.com/karpathy/nn-zero-to-hero>`_ GitHub 仓库的主页及 Discussion 区有大量学员贡献的逐行代码注释与课后作业解答。

``第二阶段：扎实理论、数理推导与领域深耕（进阶期）``

.. _standford_cs229:

Standford CS229: Machine Learning
====================================

**CS229: Machine Learning (Stanford / Andrew Ng)** 机器学习的数学根基。涵盖监督学习、无监督学习、统计学习理论、梯度下降、PAC 学习理论以及强化学习（RL）的基础数学推导。

**建议重点刷其数学推导讲义（Lecture Notes），建立对高维向量空间和概率图模型的直觉。**

- `CS229: Machine Learning 官网 <https://cs229.stanford.edu/>`_
- `Stanford Engineering Everywhere: CS229 - Machine Learning <https://see.stanford.edu/Course/CS229>`_ 提供该课程视频,文字稿(相当于字幕)以及教学笔记(pdf)，这是一个非常完整的教学资料汇总

CS229 属于硬核且数学推导密集的顶级名校课程，学习耗时远高于一般的应用型课程。这门课程的讲座笔记(Lecture Notes) 撰写极佳，数学推导严谨，被誉为机器学习领域的最佳入门教材之一。

作业与代码库（Assignments & Homeworks）: 斯坦福官网针对校外人员隐藏了部分最新提交入口，但可以在开源社区（如 GitHub 搜索 PKUFlyingPig/CS229 或 cs229-assignments）获取完整的作业题目、Python 代码框架及解答。

.. _standford_cs224n:

Stanford CS224N: Natural Language Processing with Deep Learning
=================================================================

**CS224N 大语言模型/NLP** 通过全面学习词向量、Transformer、BERT、指令微调和对齐，是通过现代LLM的桥梁。该课程是自然语言处理与大语言模型（LLM）领域的“黄金级”名校课程，兼顾了数学推导、模型架构设计与 PyTorch 代码落地。

由 NLP 界泰斗级学者 Christopher Manning 领衔，讲解极其系统，涵盖了语义学、句法分析到现代 LLM 文本生成的全过程。建议重点学习其 Transformer、Pre-training、SFT 以及 Alignment（RLHF/DPO）章节。

- `Stanford CS224N 官网 <https://web.stanford.edu/class/cs224n/>`_ 每一讲旁边均直接提供 PPT（Slides）和 PDF 讲义（Notes）的免费下载链接。涵盖词向量（Word2Vec/GloVe）、Transformer 架构、BERT/GPT 大语言模型（LLMs）、指令微调（Instruction Tuning）、RLHF 以及 Agent 智能体等最新 NLP 技术。

  - 作业发布：官网的 Assignments 页面提供了包含 Word2Vec、Dependency Parsing、Transformer 实现及 LLM 评估等 4-5 个核心编程作业 Handouts。
  - 代码框架与解答：开源社区（GitHub 搜索 CS224N assignment 或 PKUFlyingPig/CS224n-2021）维护了配套的 PyTorch 代码框架、数据文件和社区解答。
  - 推荐阅读文献（Suggested Readings）: 每节课下标注了领域经典论文（如 Attention Is All You Need、BERT、LoRA 等）及教材 Jurafsky & Martin - Speech and Language Processing (3rd ed) 的精选章节链接。

- `CS224N 2024 YouTube playlist <https://www.youtube.com/playlist?list=PLoROMvodv4rOaMFbaqxPDoLWjDaRAdP9D>`_

.. _uc_berkeley_cs285:

UC Berkeley CS285: Deep Reinforcement Learning
===============================================

**CS285 强化学习/智能体** 对RLHF、大模型对齐(PRO)或具身智能(Robotics)是很好的深度强化学习教材。涵盖策略梯度（Policy Gradients）、Actor-Critic、Q-Learning，以及现代 LLM 对齐技术（RLHF/PPO/DPO）背后的数学原理。

- `UC Berkeley CS285 官网 <https://rail.eecs.berkeley.edu/deeprlcourse/>`_ 最新教学大纲与讲义
- `UC Berkeley CS285 Deep RL, 2023 playlist <https://www.youtube.com/playlist?list=PL_iWQOsE6TfVYGEGiAOMaOzzv41Jfm_Ps>`_

CS285 是强化学习（RL）领域的顶尖研究生课程，理论推导极其严谨，兼顾算法落地与机器人控制实践:

- Lecture Slides & Notes（课堂 PPT 与详细讲义）:  `CS 185/285 at UC Berkeley: Deep Reinforcement Learning <https://rail.eecs.berkeley.edu/deeprlcourse/>`_ 每节课对应行均直接提供可下载的 PDF Slide 和补充阅读资料
- 作业与代码库（Homeworks & Starter Code）： `GitHub - berkeleydeeprlcourse/homework_fall2023 <https://github.com/berkeleydeeprlcourse/homework_fall2023>`_ 包含手写 Dagger、Policy Gradient（PPO/REINFORCE）、DQN / SAC、Model-Based RL 以及 Offline RL（CQL）等硬核 Python/PyTorch 编程作业。

由于课程包含大量概率论、Markov Decision Process (MDP) 数学推导以及复杂度很高的 RL 算法调参调试，所以学习难度和用时较高。

``第三阶段：大模型造物、底层算子与工业系统（专家期）``

.. _standford_cs336:

Stanford CS336: Language Modeling from Scratch
================================================

**CS336 大模型从零手写与系统优化** FlashAttention、数据预处理、分布式训练（DDP）和 GPU 算力优化。

- `Stanford CS336 官网 <https://cs336.stanford.edu/>`_ 最新教学大纲与讲义
- `Stanford CS336: Language Modeling from Scratch | Spring 2026 playlist <https://www.youtube.com/watch?v=JuoVZkPBiKk&list=PLoROMvodv4rMqXOcazWaTUHhq-yembLCV>`_

CS336 借鉴了经典操作系统课程“从零手写 OS”的思路，要求学员在极少脚手架代码（Minimal Scaffolding）的前提下，从零实现大语言模型全流程。这门课程是目前 Stanford 最高难度、最贴近当前 LLM 工业界底层工程的深度硬核课程(授课老师 Tri Dao 正是 FlashAttention 的发明者)。由于需要手写 CUDA/Triton 算子和分布式系统代码，对系统编程能力要求极高。

.. note::

   CS329S 和 CS320X 属于工程实战与架构设计强导向的课程，侧重于系统吞吐量、时延优化与生产环境稳定性。也就是面向大模型系统工程与 MLOps。重点攻克 LLM 的分布式训练（TP/PP/DP/Zero）、vLLM/Deepspeed/Megatron-LM 架构解析、KV Cache 管理、Speculative Decoding（投机采样）以及边缘/异构 GPU 部署。

.. _standford_cs329s:

CS 329S: Machine Learning Systems Design
=============================================

专注于传统与现代 ML 系统的完整工程生命周期（数据工程、在线/离线预测、模型部署、监控与 Data Flywheel）。

- `CS 329S: Machine Learning Systems Design官网 <https://stanford-cs329s.github.io/>`_ Chip Huyen 整理的课程 Notes（即开源图书 Designing Machine Learning Systems 的前身与补充）

.. _standford_cs329x:

CS 329X: Human-Centered LLMs
===============================

专注于大模型系统架构与复合 AI 系统（Compound AI Systems），内容涵盖 DSPy 自动 Prompt/管道编译、RAG 检索增强系统、推理加速与 LLM 部署服务栈。

- `CS 329X: Human-Centered LLMs 官网 <https://web.stanford.edu/class/cs329x/>`_ 和 `Matei Zaharia团队主页 <https://people.eecs.berkeley.edu/~matei/>`_
- `Stanford Online (youtube) <https://www.youtube.com/@stanfordonline>`_ 上我没有找到这个课程视频

- `DSPyk视频列表 <https://www.youtube.com/watch?v=41EfOY0Ldkc&list=PLTdF0Vr8q9lCY4QHuEVQQHaC4erqU4Oph>`_ 全面解释可以参考

参考
======

- gemini
