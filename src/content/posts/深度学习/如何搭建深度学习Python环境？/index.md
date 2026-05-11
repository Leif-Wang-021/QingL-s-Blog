---
title: 如何搭建深度学习 Python 环境？
published: 2026-05-11
description: ""
image: "./cover.png"
tags: []
category: 深度学习
draft: false
---

# 开始

作为一个电子信息类专业硬件方向的学生，初次接触深度学习与通信算法实在十分头大。( ´•̥̥̥ω•̥̥̥｀ )非常感谢知乎博主[咖啡因是恶魔](https://www.zhihu.com/people/dong-ye-zi-icycoconut)的教程[《我该干啥》之新手如何入门深度学习](https://zhuanlan.zhihu.com/p/27337809985)，让我对深度学习的入门与环境搭建有了一个非常直观的理解。

根据大佬的教程，我完成了 Python 环境的搭建，并在 VSCode 中安装了相应插件，完成了部分代码的调试。

# 深度学习为什么要使用 Python？

## Python 是什么？

在最初，我对 Python 的了解也十分浅显，我首先接触的是 C 语言，在朋友的介绍下，我对 Python 的理解是一种很适合调用现成工具、快速完成实验的编程语言。

实际上 Python 是一种高级编程语言。所谓“高级”，不是说它比 C 更厉害，而是说它离人的表达方式更近，很多细节不用程序员手动处理。比如变量类型、内存管理、字符串处理、文件读取、画图、矩阵计算等，Python 都提供了比较方便的写法。

我最初的理解“Python 是一种有很多现成库可以调用的语言”。这个理解虽然不完整，但很适合初学深度学习：在深度学习中，我们通常不会从零实现矩阵运算、神经网络、反向传播和 GPU 加速，而是调用 `numpy`、`pandas`、`matplotlib`、`torch` 等库完成实验。

### Python 和 C 的区别

因此最直观的区别是：C 更接近底层，Python 更接近应用和实验。

| 对比 | C 语言 | Python |
|---|---|---|
| 定位 | 偏底层、系统、性能 | 偏应用、脚本、科研实验 |
| 写法 | 更严格、更繁琐 | 更简洁、更接近自然表达 |
| 运行方式 | 通常先编译再运行 | 通常由解释器直接运行 |
| 内存管理 | 程序员更需要关心指针和内存 | 大多数时候自动管理 |
| 性能 | 通常更快 | 本身较慢，但可调用底层高性能库 |
| 生态 | 系统开发、嵌入式、底层算法 | 数据分析、AI、自动化、Web、科研 |
| 深度学习 | 可以做底层实现，但开发成本高 | 主流选择，PyTorch/TensorFlow 生态成熟 |

比如打印一句话：

```c
// 引入标准输入输出库，printf 函数来自这里
#include <stdio.h>

// C 程序从 main 函数开始执行
int main() {
    // 在终端输出一句话
    printf("hello deep learning\n");
    return 0;
}
```

Python 写法是：

```python
# 直接调用 Python 内置的 print 函数，在终端输出一句话
print("hello deep learning")
```

相比 C 语言，Python 的语法更接近人的表达习惯。很多时候，我们只需要描述“我要做什么”，而不必过多关心底层细节。例如做矩阵运算、画图、训练神经网络时，只要当前环境中安装了对应的库，就可以通过 `import` 导入并使用其中封装好的函数和类。

但这不代表 Python 在所有方面都比 C 强。C 的优势是性能高、控制力强，很多底层库、操作系统、驱动、嵌入式程序都离不开 C。Python 的优势是开发效率高，尤其适合科研中快速验证想法，库的安装、导入和使用都比较方便，很多复杂功能已经被别人封装好。

比如：

```python
# 导入 numpy 库，并给它起一个常用别名 np
import numpy as np

# 创建一个包含 1、2、3 的数组
x = np.array([1, 2, 3])

# 计算数组平均值并输出
print(x.mean())
```

这里 `numpy` 就是库，`mean()` 是库里已经写好的函数。

C 更像是在告诉计算机“具体怎么做”，Python 更像是在调用工具完成“我要做什么”。

## 为什么要使用 Python？

Python 背后那些工具，很多其实就是 C/C++/CUDA 写的。深度学习里常见的情况是：

比如 PyTorch 看起来是 Python 代码：

```python
# 导入 PyTorch 库
import torch

# 随机生成一个 1000 x 1000 的矩阵，并把它放到 GPU 上计算
x = torch.randn(1000, 1000).cuda()

# 使用 @ 做矩阵乘法，真正的大量计算会交给底层库和 GPU 执行
y = x @ x
```

但真正的大矩阵乘法是在底层高性能代码和 GPU 上执行的。所以 Python 在深度学习中更像是一个“实验控制台”：我们用它组织数据、调用模型、启动训练、画图分析，而底层计算由优化好的库完成。

Python 的优势是：

1. 语法简单，适合把注意力放在模型和实验上
2. 深度学习生态最完整：PyTorch、TensorFlow、`NumPy`、`Matplotlib`（一些深度学习可以使用的库）
3. 科研代码和论文复现大多用 Python
4. 数据处理、画图、训练模型可以在同一种语言里完成

Python 的优势在于，它可以通过“一种语言 + 大量成熟库”的方式，完成一个项目中的许多环节，非常全能！比如在深度学习项目中，Python 既可以用来处理数据，也可以用来搭建模型、训练模型、保存结果和画图分析。这样我们不需要频繁切换不同工具，而是可以在同一个 Python 环境中完成大部分实验流程。

# 配置 Python 环境

在初步了解 Python 的优势之后，就可以开始配置 Python 环境了。从 Python 官网直接可以下载安装 Python。它的流程一般是：

1. 打开 Python 官网
2. 下载适合 Windows 的 Python 安装包
3. 安装时勾选 `Add Python to PATH`
4. 安装完成后打开终端
5. 输入 `python --version` 检查是否安装成功
6. 输入 `pip --version` 检查 `pip` 是否可用
7. 使用 `pip` 安装需要的库

在安装完成后，就可以在终端中运行 Python 命令以检查环境是否配置成功，例如：

```powershell
# 查看当前终端能调用到的 Python 版本
python --version

# 查看 pip 是否可用，以及 pip 的版本
pip --version
```

当终端正常显示 Python 和 `pip` 的版本信息时，环境配置成功。这种方式比较直接，适合学习 Python 基础语法、小脚本、简单自动化任务。但当处理深度学习这样复杂的任务时，就需要做好环境与 Python 版本的管理。

## Python 的环境管理

Python 的环境管理有很多种方法，这里介绍两种最常用的方法：`.venv` 和 `.conda`。

`.venv` 和 `.conda` 都可以理解为“项目专用环境”。它们的目的类似：让一个项目有自己独立的 Python 和第三方库，避免不同项目之间互相影响。

比如普通 Python 常用：

```powershell
# 使用当前 Python 创建一个名为 .venv 的虚拟环境
# .venv 会作为当前项目的独立 Python 环境，用来存放本项目需要的库
python -m venv .venv

# 激活 .venv 虚拟环境
# 激活后，终端中运行 python / pip 时，会优先使用 .venv 里的版本
.\.venv\Scripts\Activate.ps1

# 在当前虚拟环境中安装项目需要的第三方库
# numpy 用于数值计算，matplotlib 用于画图，pandas 用于表格数据处理
pip install numpy matplotlib pandas

```

这会在项目里创建一个 `.venv` 文件夹，用 `pip` 安装库。

此时 `.venv` 就像一个小工具箱，内部存放了所有你本工程需要的 Python 和库。每次进入项目时，先激活这个环境，就可以使用里面的工具了。

`.venv` 作为 Python 自带的虚拟环境工具，适合普通 Python 项目。比如写脚本、做小工具、学习基础语法时，用 `.venv` + `pip` 完全够用。

但深度学习项目的依赖更复杂。它通常不只是安装几个普通 Python 包，还会涉及：

- Python 版本
- PyTorch / TensorFlow 版本
- CUDA 版本
- `numpy` / `scipy` / `opencv` 版本
- 显卡驱动兼容性


如果只用 `.venv`，库主要通过 `pip` 安装。对于普通库来说没问题，但遇到科学计算、深度学习、GPU 相关依赖时，更容易碰到版本不兼容，此时就需要引入 `conda` 来管理环境。

## Anaconda 是什么？

Anaconda 可以理解为一个面向数据科学、机器学习和深度学习的 Python 工具平台。它不是单纯的 Python，而是把 Python、环境管理工具、包管理工具和一些常用科学计算工具整合在一起。

`conda` 作为 Anaconda 的核心组件，其作用是管理环境和安装库。官方文档也把 `conda` 定位为包管理和环境管理工具，可以在 Windows、macOS、Linux 上使用。可以参考：[`conda` 官方文档](https://docs.conda.io/projects/conda/en/stable/index.html)。

`conda` 可以更方便地创建多个独立环境。不同环境里可以安装同一个库的不同版本。遇到版本不兼容时，可以切换到不同环境，而不是在同一个环境里硬改来改去。

比如：

> 环境 A：  
> Python 3.12  
> PyTorch 2.11  
> `numpy` 2.x  

> 环境 B：  
> Python 3.10  
> PyTorch 1.x  
> `numpy` 1.x


使用时切换环境：

```powershell
conda activate env_a
```

或者：

```powershell
conda activate env_b
```

`venv` 其实也能做到“多个环境安装不同版本的库”，也可以分别安装不同版本的 `numpy`。

真正的区别是：

- `venv` 也能隔离环境，但主要依赖系统已有 Python + `pip`
- `conda` 更擅长管理 Python 版本和科学计算/深度学习相关依赖

`conda` 可以更方便地创建多个独立环境，每个环境可以指定不同的 Python 版本，并安装适合该项目的一组库。当不同项目之间出现版本冲突时，我们可以通过切换环境来解决，而不是让所有项目共用同一套库。`venv` 也能创建独立环境，但在 Python 版本管理和科学计算依赖管理方面，`conda` 通常更方便。

## 安装 Anaconda 并配置环境

按照教程的思路，如果完全不知道该如何开始，可以先把 Anaconda 安装好，再用 `conda` 为当前项目创建一个独立的 Python 环境。这样做的好处是：系统里的 Python、Anaconda 自带的 `base` 环境、当前项目环境三者可以分开，不容易互相影响。

我这里的实际安装规划是：

```text
# Anaconda 本体安装位置
Anaconda：D:\Anaconda3

# 深度学习项目位置
项目目录：F:\DeepLearningStudy

# 当前项目专属环境
项目环境：F:\DeepLearningStudy\.conda
```

这里我没有把 Anaconda 安装到 `D:\Program Files` 这类带空格的路径下，而是直接安装到 `D:\Anaconda3`。这样路径更简单，也能减少一些工具因为路径空格产生的奇怪问题。

### 第一步：安装 Anaconda

首先从 Anaconda 官网下载安装包：

[Anaconda 官方下载地址](https://www.anaconda.com/download)

安装时需要注意几点：

1. 安装位置可以自己指定，例如我使用的是 `D:\Anaconda3`
2. 不建议把 Anaconda 注册成系统默认 Python
3. 不建议随意把 Anaconda 加入全局 `PATH`
4. 后续通过 `conda init powershell` 让 PowerShell 能识别 `conda`

安装完成后，可以在 PowerShell 中检查 `conda` 是否可用：

```powershell
# 查看 conda 是否安装成功
conda --version
```

如果能看到类似下面的输出，就说明 Anaconda/conda 已经可以使用：

```text
# conda 的版本号
conda 25.11.1
```

如果 PowerShell 里暂时无法识别 `conda`，可以使用 Anaconda 的完整路径进行初始化：

```powershell
# 初始化 PowerShell，让以后新打开的终端可以直接使用 conda
D:\Anaconda3\Scripts\conda.exe init powershell
```

执行完成后，关闭当前 PowerShell 或 VSCode 终端，再重新打开一个新的终端。因为终端环境变量和初始化脚本通常需要重新打开后才会生效。

### 第二步：创建项目文件夹

接着创建一个专门用于学习深度学习的项目文件夹。我这里使用的是：`F:\DeepLearningStudy`


这个文件夹可以理解为整个项目的根目录，后面所有代码、数据处理脚本、模型文件都会围绕它展开。

### 第三步：创建当前项目的 conda 环境

进入项目目录后，使用 `conda` 创建一个项目专属环境：

```powershell
# 进入项目目录
cd F:\DeepLearningStudy

# 在当前项目中创建 .conda 环境，并指定 Python 版本为 3.12
conda create --prefix F:\DeepLearningStudy\.conda python=3.12
```

这里的含义是：

```text
# --prefix 后面指定环境保存在哪里
--prefix F:\DeepLearningStudy\.conda

# python=3.12 表示这个环境使用 Python 3.12
python=3.12
```

我没有直接把环境创建成一个全局名字，而是放在项目目录下的 `.conda` 文件夹中。这样打开项目时，一眼就能看出这个项目自己的 Python 环境在哪里。

### 第四步：激活项目环境

环境创建完成后，需要先激活它：

```powershell
# 激活当前项目的 conda 环境
conda activate F:\DeepLearningStudy\.conda
```

激活成功后，终端前面一般会出现类似环境名或路径的提示。此时再运行 `python` 或 `pip`，使用的就是当前项目环境里的版本，而不是系统里的 Python。

可以用下面的命令检查：

```powershell
# 查看当前 Python 版本
python --version

# 查看当前 python.exe 来自哪里
where.exe python
```

如果 `where.exe python` 的结果中出现：

```text
# 当前项目环境中的 Python
F:\DeepLearningStudy\.conda\python.exe
```

就说明当前终端已经在使用项目自己的 Python 环境。

### 第五步：安装基础库

接下来安装教程中提到的一些常用库：

```powershell
# 安装深度学习前期常用的基础库
conda install numpy pandas scipy matplotlib scikit-learn nltk opencv tqdm
```

这些库的作用大致是：

- `numpy`：数值计算和矩阵操作
- `pandas`：表格数据处理
- `scipy`：科学计算
- `matplotlib`：画图
- `scikit-learn`：机器学习工具
- `nltk`：自然语言处理工具
- `opencv`：图像处理，代码中通常通过 `cv2` 导入
- `tqdm`：显示训练进度条

安装完成后，可以写一个简单的检查命令：

```powershell
# 检查这些库是否能够正常导入
python -c "import numpy, pandas, scipy, matplotlib, sklearn, nltk, cv2, tqdm; print('basic libraries ok')"
```

如果终端输出：

```text
# 基础库导入成功
basic libraries ok
```

说明这些基础库已经能够正常使用。

### 第六步：安装 PyTorch

PyTorch 较为复杂，它与 Python 版本、显卡、CUDA 版本都有关系。更稳妥的方式是去 PyTorch 官网选择适合自己电脑的安装命令：[PyTorch 官方安装页面](https://pytorch.org/get-started/locally/)

我的电脑有 NVIDIA 显卡，所以选择的是 Windows + `pip` + CUDA 版本的安装方式。实际命令类似：

```powershell
# 安装支持 CUDA 12.8 的 PyTorch、torchvision 和 torchaudio
python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
```

这里使用 `pip` 是因为 PyTorch 官网会根据当前平台给出推荐命令。也就是说，即使使用 `conda` 创建环境，后续也可以在这个环境中使用 `pip` 安装某些库。

### 第七步：检查 PyTorch 是否能使用 GPU

安装完成后，需要检查 PyTorch 是否真的能调用显卡：

```powershell
# 检查 PyTorch 版本、CUDA 是否可用、当前使用的 GPU 名称
python -c "import torch; print('torch', torch.__version__); print('cuda available:', torch.cuda.is_available()); print('cuda version:', torch.version.cuda); print('gpu:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU only')"
```

如果输出中有：

```text
# CUDA 可用，说明 PyTorch 可以调用 NVIDIA GPU
cuda available: True

# 显示当前显卡名称
gpu: NVIDIA GeForce RTX 3070 Ti Laptop GPU
```

就说明 PyTorch 已经能够使用显卡进行深度学习计算。

### 第八步：整理项目结构

环境配置好之后，可以开始整理项目结构。按照教程中的建议，我将当前项目整理成：

```text
# 项目根目录
F:\DeepLearningStudy

# 当前项目的 conda 环境
├─ .conda

# 数据读取、数据处理相关代码
├─ Dataset

# 神经网络模型相关代码
├─ Model

# 训练、验证、测试相关代码
├─ TrainEvalTest

# 环境检查脚本
├─ hello.py

# 项目入口文件
└─ main.py
```

这种结构的好处是比较清楚：

- `Dataset` 负责和数据相关的内容
- `Model` 负责神经网络结构
- `TrainEvalTest` 负责训练、验证和测试流程
- `main.py` 作为整个项目的入口

到这里，一个最基础的深度学习 Python 环境就搭建完成了。后面真正写模型代码时，就可以在这个环境中继续安装需要的库、运行训练脚本、保存实验结果。
