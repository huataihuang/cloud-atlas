#!/usr/bin/env bash
set -e

echo "🚀 Starting AI Cloud Atlas structure initialization..."

# 1. 创建全局唯一的自研算法库源码目录 (纯英文/标准 nbdev 结构)
mkdir -p packages/nbs packages/custom_optimizer

# 2. 创建英文版目录结构 (课程 + 自研库双语导读区)
mkdir -p en/courses/fastai en/courses/nn-zero-to-hero en/courses/stanford-cs229 en/packages

# 3. 创建中文版目录结构 (课程 + 自研库双语导读区)
mkdir -p zh/courses/fastai zh/courses/nn-zero-to-hero zh/courses/stanford-cs229 zh/packages

# ==========================================
# 4. 生成英文版网站配置与占位文件
# ==========================================
cat << 'EOF' > en/_quarto.yml
project:
  type: website
  output-dir: _site

website:
  title: "Cloud Atlas - AI"
  navbar:
    background: primary
    left:
      - href: index.qmd
        text: "Home"
      - href: courses/fastai/index.qmd
        text: "Courses"
      - href: packages/index.qmd
        text: "Packages Guide"
    right:
      - text: "🌐"
        menu:
          - href: index.html
            text: "English"
          - href: ../zh/index.html
            text: "中文"
  sidebar:
    - title: "AI Courses"
      contents:
        - courses/fastai/index.qmd
        - courses/nn-zero-to-hero/index.qmd
        - courses/stanford-cs229/index.qmd
    - title: "Custom Packages"
      contents:
        - packages/index.qmd

format:
  html:
    theme: cosmo
    toc: true
EOF

cat << 'EOF' > en/index.qmd
---
title: "Home"
---

English AI Hub.
EOF

cat << 'EOF' > en/courses/fastai/index.qmd
---
title: "Fast.ai: Practical Deep Learning"
---

Notes for Fast.ai.
EOF

cat << 'EOF' > en/courses/nn-zero-to-hero/index.qmd
---
title: "Neural Networks: Zero to Hero"
---

Notes for Andrej Karpathy's Zero to Hero.
EOF

cat << 'EOF' > en/courses/stanford-cs229/index.qmd
---
title: "Stanford CS229: Machine Learning"
---

Notes for Stanford CS229.
EOF

cat << 'EOF' > en/packages/index.qmd
---
title: "Custom Packages Guide"
---

Getting started guide and tutorials referencing the root `packages/` library.
EOF

# ==========================================
# 5. 生成中文版网站配置与占位文件
# ==========================================
cat << 'EOF' > zh/_quarto.yml
project:
  type: website
  output-dir: _site

website:
  title: "云图 - AI"
  navbar:
    background: primary
    left:
      - href: index.qmd
        text: "首页"
      - href: courses/fastai/index.qmd
        text: "课程中心"
      - href: packages/index.qmd
        text: "自研库指南"
    right:
      - text: "🌐"
        menu:
          - href: ../en/index.html
            text: "English"
          - href: index.html
            text: "中文"
  sidebar:
    - title: "AI 课程专区"
      contents:
        - courses/fastai/index.qmd
        - courses/nn-zero-to-hero/index.qmd
        - courses/stanford-cs229/index.qmd
    - title: "自研算法库导读"
      contents:
        - packages/index.qmd

format:
  html:
    theme: cosmo
    toc: true
EOF

cat << 'EOF' > zh/index.qmd
---
title: "首页"
---

中文 AI 研发中心首页。
EOF

cat << 'EOF' > zh/courses/fastai/index.qmd
---
title: "Fast.ai: 实用深度学习"
---

Fast.ai 课程实战与 Tesla A2 训练笔记。
EOF

cat << 'EOF' > zh/courses/nn-zero-to-hero/index.qmd
---
title: "Neural Networks: Zero to Hero"
---

Andrej Karpathy 神经网络零基础到精通系列笔记。
EOF

cat << 'EOF' > zh/courses/stanford-cs229/index.qmd
---
title: "Stanford CS229: 机器学习"
---

斯坦福大学经典机器学习公开课笔记。
EOF

cat << 'EOF' > zh/packages/index.qmd
---
title: "自研算法库导读"
---

本页面由中文编写，指引读者如何调用和体验根目录下统一的 `packages/` Python 源码库。
EOF

# ==========================================
# 6. 生成根目录 packages 源码占位说明
# ==========================================
cat << 'EOF' > packages/README.md
# Packages Root

Single source of truth for Python algorithms (nbdev-driven).
EOF

echo "✅ Advanced Multilingual Multi-Course Architecture initialized successfully!"
