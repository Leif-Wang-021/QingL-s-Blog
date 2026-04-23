***

# An Iteratively Weighted MMSE Approach to Distributed Sum-Utility Maximization for a MIMO Interfering Broadcast Channel

**作者：** Qingjiang Shi，Meisam Razaviyayn，Zhi-Quan Luo（IEEE Fellow），Chen He（IEEE Member）

## 摘要
考虑多输入多输出（MIMO）干扰广播信道：蜂窝网络中的多个基站在各自小区内同时向一组用户发送信号，同时彼此产生干扰。其核心问题是设计线性波束形成器以最大化系统吞吐量。本文提出一种基于迭代最小化加权均方误差（MSE）的加权和速率最大化线性收发器设计算法。所提算法仅需本地信道信息，并收敛到加权和速率最大化问题的一个驻点。此外，该算法及其收敛性还可扩展到更一般的一类和效用最大化问题。数值实验验证了所提算法的有效性。

关键词：线性波束形成，MIMO 干扰广播信道，和效用最大化，加权 MMSE，加权和速率最大化。

---

## I. 引言
考虑一个多输入多输出（MIMO）干扰广播信道（IBC）：若干发射机（每个配备多根天线）希望同时向各自目标接收机发送独立数据流。作为多用户下行通信的通用模型，MIMO-IBC 可用于研究许多实际系统，例如数字用户线（DSL）、认知无线电系统、自组织无线网络以及蜂窝无线通信等。遗憾的是，尽管该问题非常重要且已被深入研究多年，如何找到能够最大化 MIMO-IBC 全体用户加权和速率的最优发射/接收策略，仍然相当困难。事实上，即便在更简单的 MIMO 干扰信道情形下，最优策略也仍未知。

对容量区域认知不足促使研究者采取一种务实路径：将干扰视为噪声，并在线性收发策略类内搜索以最大化加权和速率。干扰信道（IFC，IBC 的特例）中的加权和速率最大化近年来一直是研究热点。从优化角度看，该问题是非凸且 NP-hard，即使在单天线情形下也是如此。因此，当前大多数研究聚焦于高质量次优解的高效求解。

例如，为便于分布式实现，已有工作提出了用于 IFC 加权和速率最大化的非合作博弈方法，包括两用户 IFC、单输入单输出（SISO）和多输入单输出（MISO）IFC，以及无复用（即每用户一条数据流）的 MIMO IFC 分布式算法。在这类博弈方法中，用户被视为博弈参与者，各自贪心地最大化自身效用/收益函数。由于每个用户只需本地信道信息，这类方法非常适合分布式实现，但其收敛点仅为纳什均衡，可能与和速率最优点相距较远。

相比之下，所谓基于干扰定价的方法让每个用户最大化“自身效用减去由干扰价格决定的干扰代价”。若将干扰价格选为“干扰功率每增加单位导致的总效用边际下降”，则该方法可收敛到整体效用最大化问题的驻点（而非纳什均衡）。已有研究在一组效用函数下证明了干扰定价算法收敛到驻点，但不包含标准 Shannon 速率函数。随后又有若干针对 SISO 和 MISO IFC 的扩展与变体，被证明可单调收敛到加权和速率最大化问题的驻点。对于 MIMO 干扰信道也有类似算法，但未考虑复用（每用户单流）。这类算法通常一次仅允许一个用户更新波束形成器，可能带来过高的价格交换通信开销。

也有工作针对“无复用 MIMO 干扰信道”提出了可多用户同时更新的一般分布式干扰定价算法，但未给出收敛性分析。DBA-RF 算法本质上也是分布式定价算法，只是采用了不同的定价策略。若将接收端结构固定为标准线性接收机（如 MMSE 或零迫），线性收发器设计可化为发射协方差矩阵设计问题。已有研究基于梯度投影法给出迭代算法；在可获得信道状态信息及其他用户协方差矩阵时，每个用户可本地更新自身协方差矩阵。另有研究基于局部线性近似，提出分布式算法，让每个用户通过求解一个凸优化问题来更新协方差矩阵；这可视为顺序分布式定价算法的 MIMO 扩展。上述算法被统一称为迭代线性近似（ILA）算法。由于它们对加权和速率目标使用了局部紧凹下界近似，因而可保证速率单调上升，并使发射协方差矩阵收敛到原目标函数的驻点。

另一种和速率最大化方法用于 MIMO 广播下行信道：将加权和速率最大化转化为等价的加权和 MSE 最小化（WMMSE）问题，其中权矩阵依赖于最优波束形成矩阵。由于权矩阵通常未知，已有工作提出通过迭代自适应选取权矩阵并更新线性收发波束形成器的算法；其构造了一个非凸代价函数并证明该代价随迭代单调下降。然而，迭代点是否收敛到该代价函数的驻点（或全局最小值）仍未知。针对每用户单流的干扰信道，也有类似算法。

受上述工作启发并结合块坐标下降技术，本文提出一种简单的分布式线性收发器设计方法，称为 WMMSE 算法，用于干扰广播信道中的一般效用最大化。该算法在多个方向扩展了现有工作：可处理较一般的效用函数（加权和速率只是其特例），并适用于一般 MIMO 干扰广播信道。此外，所提 WMMSE 还能扩展以容纳信道估计误差，从而实现鲁棒加权和速率最大化。理论上，WMMSE 生成的迭代序列至少收敛到效用最大化问题的一个局部最优点，同时具有较低通信与计算复杂度。

本文采用如下记号：矩阵的 Hermitian 转置用上标表示，复共轭用上划线表示。矩阵使用粗体大写字母，向量使用粗体小写字母，标量使用普通小写字母。单位矩阵记为 $I$，$\mathbb{C}^{m\times n}$ 表示 $m\times n$ 维复空间。复高斯与实高斯分布分别记为 $\mathcal{CN}(\cdot,\cdot)$ 与 $\mathcal{N}(\cdot,\cdot)$。$\mathbb{E}(\cdot)$、$Tr(\cdot)$、$det(\cdot)$ 分别表示期望、迹与行列式算子。$\nabla f(\cdot)$ 表示函数 $f(\cdot)$ 的梯度。对称矩阵 $A$ 与 $B$，$A>B$（$A\ge B$）表示 $A-B$ 正定（半正定）。

---

## II. 系统模型与问题表述
考虑一个 $K$ 小区干扰广播信道。基站 $k$（$k=1,2,...,K$）配备 $M_{k}$ 根发射天线，并服务于小区 $k$ 内的 $I_{k}$ 个用户。定义 $i_{k}$ 为小区 $k$ 的第 $i$ 个用户，$N_{i_{k}}$ 为接收机 $i_{k}$ 的接收天线数。定义全体接收机集合为
$\mathcal{I}=\{i_{k}|k\in \{1,2,..., K\}, i \in \{1,2,..., I_{k}\}\}$。

设 $V_{i_{k}}\in\mathbb{C}^{M_{k}\times d_{i_{k}}}$ 表示基站 $k$ 向接收机 $i_{k}$ 发送信号 $s_{i_{k}}\in\mathbb{C}^{d_{i_{k}}\times1}$ 时采用的波束形成器（$i=1,2,...,I_{k}$）。发射信号为
$x_{k}=\sum_{i=1}^{I_{k}}V_{i_{k}}s_{i_{k}}$，并假设 $\mathbb{E}[s_{i_{k}}s_{i_{k}}^{H}]=I$。

在线性信道模型下，接收机 $i_{k}$ 处接收信号 $y_{i_{k}}\in\mathbb{C}^{N_{i_{k}}\times1}$ 可写为：
$$y_{i_{k}} = H_{i_{k}k}V_{i_{k}}s_{i_{k}} + \sum_{m=1,m\ne i}^{I_{k}}H_{i_{k}k}V_{m_{k}}s_{m_{k}} + \sum_{j\ne k,j=1}^{K}\sum_{l=1}^{I_{j}}H_{i_{k}j}V_{lj}s_{lj} + n_{i_{k}}$$
该式分别对应期望信号、同小区干扰、跨小区干扰与噪声。

其中，$H_{i_{k}j}\in\mathbb{C}^{N_{i_{k}}\times M_{j}}$ 表示从发射机 $j$ 到接收机 $i_{k}$ 的信道矩阵；$n_{i_{k}}\in\mathbb{C}^{N_{k}\times1}$ 为加性白高斯噪声，服从 $\mathcal{CN}(0,\sigma_{i_{k}}^{2}I)$。假设不同用户信号彼此独立，且与接收噪声独立。

本文将干扰视为噪声，并采用线性接收波束形成，即估计信号为
$\hat{s}_{i_{k}}=U_{i_{k}}^{H}y_{i_{k}}$，$\forall i_{k}\in\mathcal{I}$。
于是，目标是寻找发射与接收波束形成器 $\{V, U\}$，在满足每个发射机功率预算
$\sum_{i=1}^{I_{k}}Tr(V_{i_{k}}V_{i_{k}}^{H})\le P_{k}$ 的前提下，使系统某种效用最大化，其中 $P_{k}$ 为发射机 $k$ 的功率预算。

下面先讨论常见的和速率效用函数，并说明加权和速率最大化问题可与矩阵加权和 MSE 最小化问题关联；随后推广到更一般效用函数。

### A. 加权和速率最大化与矩阵加权和 MSE 最小化
一种常见效用最大化问题是加权和速率最大化：
$$\begin{aligned} \max_{V} &\sum_{k=1}^{K}\sum_{i_{k}=1}^{I_{k}}\alpha_{i_{k}}R_{i_{k}} \\ \text{s.t. } &\sum_{i=1}^{I_{k}}Tr(V_{i_{k}}V_{i_{k}}^{H})\le P_{k},\quad \forall k=1,2,...,K \quad \text{(1)} \end{aligned}$$
其中，$R_{i_{k}}$ 为用户 $i_{k}$ 的速率（见式 (2)）；权重 $\alpha_{i_{k}}$ 表示用户 $i_{k}$ 的优先级。速率定义为：
$$R_{i_{k}} \triangleq \log\det\left(I+H_{i_{k}k}V_{i_{k}}V_{i_{k}}^{H}H_{i_{k}k}^{H}\left(\sum_{(l,j)\ne(i,k)}H_{i_{k}j}V_{lj}V_{lj}^{H}H_{i_{k}j}^{H}+\sigma_{i_{k}}^{2}I\right)^{-1}\right) \quad \text{(2)}$$

MIMO-IBC 中另一个常见效用最大化问题是和 MSE 最小化。在 $s_{i_{k}}$ 与 $n_{i_{k}}$ 独立假设下，MSE 矩阵为：
$$\begin{aligned} E_{i_{k}} &\triangleq \mathbb{E}_{s,n}[(\hat{s}_{i_{k}}-s_{i_{k}})(\hat{s}_{i_{k}}-s_{i_{k}})^{H}] \\ &= (I-U_{i_{k}}^{H}H_{i_{k}k}V_{i_{k}})(I-U_{i_{k}}^{H}H_{i_{k}k}V_{i_{k}})^{H} + \sum_{(l,j)\ne(i,k)}U_{i_{k}}H_{i_{k}j}V_{l_{j}}V_{l_{j}}^{H}H_{i_{k}j}^{H}U_{i_{k}}^{H} + \sigma_{i_{k}}^{2}U_{i_{k}}^{H}U_{i_{k}} \quad \text{(3)} \end{aligned}$$
对应和 MSE 最小化问题：
$$\begin{aligned} \min_{U,V} &\sum_{k=1}^{K}\sum_{i=1}^{I_{k}}Tr(E_{i_{k}}) \\ \text{s.t. } &\sum_{i=1}^{I_{k}}Tr(V_{i_{k}}V_{i_{k}}^{H})\le P_{k}, \quad k=1,2,...,K \quad \text{(4)} \end{aligned}$$

固定全部发射波束形成器 $V$ 并最小化（加权）和 MSE，可得到著名的 MMSE 接收机：
$$U_{i_{k}}^{mmse} = J_{i_{k}}^{-1}H_{i_{k}k}V_{i_{k}} \quad \text{(5)}$$
其中，
$J_{i_{k}} \triangleq \sum_{j=1}^{K}\sum_{l=1}^{I_{j}}H_{i_{k}j}V_{l_{j}}V_{l_{j}}^{H}H_{i_{k}j}^{H}+\sigma_{i_{k}}^{2}I$
是接收机 $i_{k}$ 总接收信号协方差矩阵。对应 MSE 矩阵为：
$$E_{i_{k}}^{mmse} = I - V_{i_{k}}^{H}H_{i_{k}k}^{H}J_{i_{k}}^{-1}H_{i_{k}k}V_{i_{k}} \quad \text{(6)}$$

下述结果建立了加权和速率最大化与矩阵加权和 MSE 最小化之间的等价关系。

定理 1：设 $W_{i_{k}}\ge0$ 为接收机 $i_{k}$ 的权矩阵。问题
$$\begin{aligned} \min_{W,U,V} &\sum_{k=1}^{K}\sum_{i=1}^{I_{k}}\alpha_{i_{k}}(Tr(W_{i_{k}}E_{i_{k}})-\log\det(W_{i_{k}})) \\ \text{s.t. } &\sum_{i=1}^{I_{k}}Tr(V_{i_{k}}V_{i_{k}}^{H})\le P_{k},\quad k=1,2,...,K \quad \text{(7)} \end{aligned}$$
与加权和速率最大化问题 (1) 等价，即两者的全局最优解 $V$ 相同。

定理 1 的证明见附录 A。为直观说明，考虑 SISO 干扰信道特例。此时所有信道矩阵 $H_{i_{k}j}$ 均退化为标量，记为 $h_{i_{k}j}$。则和速率最大化问题 (1) 可化为：
$$\begin{aligned} \max_{v} &\sum_{k=1}^{K}\sum_{i=1}^{I_{k}}\log\left(1+\frac{|h_{i_{k}k}|^{2}|v_{i_{k}}|^{2}}{\sum_{(j,l)\ne(k,i)}|h_{i_{k}j}|^{2}|v_{l_{j}}|^{2}+\sigma_{i_{k}}^{2}}\right) \\ \text{s.t. } &\sum_{i=1}^{I_{k}}|v_{i_{k}}|^{2}\le P_{k}, \quad k=1,2,...,K \quad \text{(8)} \end{aligned}$$
该问题等价于如下加权和 MSE 最小化：
$$\begin{aligned} \min_{w,u,v} &\sum_{k=1}^{K}\sum_{i=1}^{I_{k}}(w_{i_{k}}e_{i_{k}}-\log w_{i_{k}}) \\ \text{s.t. } &\sum_{i=1}^{I_{k}}|v_{i_{k}}|^{2}\le P_{k}, \quad k=1,2,...,K \quad \text{(9)} \end{aligned}$$
其中 $w_{i_{k}}$ 为正权变量，$e_{i_{k}}$ 为均方估计误差：
$$e_{i_{k}} \triangleq |u_{i_{k}}h_{i_{k}k}v_{i_{k}}-1|^{2}+\sum_{(j,l)\ne(k,i)}|u_{i_{k}}h_{i_{k}j}v_{l_{j}}|^{2}+\sigma_{i_{k}}^{2}|u_{i_{k}}|^{2}$$

为说明等价性，可由一阶最优条件求得最优 $w_{i_{k}}$ 与 $u_{i_{k}}$：
$$u_{i_{k}}^{opt} = \frac{h_{i_{k}k}v_{i_{k}}}{\sum_{j=1}^{K}\sum_{l=1}^{I_{j}}|h_{i_{k}j}|^{2}|v_{l_{j}}|^{2}+\sigma_{i_{k}}^{2}}, \quad w_{i_{k}}^{opt} = e_{i_{k}}^{-1}$$
将其代回并化简 (9)，得到等价优化问题：
$$\begin{aligned} \max_{v} &\sum_{k=1}^{K}\sum_{i=1}^{I_{k}}\log\left(1-\frac{|h_{i_{k}k}|^{2}|v_{i_{k}}|^{2}}{\sum_{j=1}^{K}\sum_{l=1}^{I_{j}}|h_{i_{k}j}|^{2}|v_{l_{j}}|^{2}+\sigma_{i_{k}}^{2}}\right)^{-1} \\ \text{s.t. } &\sum_{i=1}^{I_{k}}|v_{i_{k}}|^{2}\le P_{k}, \quad k=1,2,...,K \end{aligned}$$
其进一步等价于 (8)。

上述等价关系表明：可通过加权 MSE 最小化 (9) 来实现和速率最大化。后者在 $(u,v,w)$ 空间中更易处理，因为固定其余变量时每一块子问题均为凸且容易求解（通常有闭式解）。这将用于第 III 节 WMMSE 算法设计。相比之下，原始和速率最大化问题 (8) 对变量 $v$ 非凸，直接优化较困难。

### B. 一般效用最大化
问题 (1) 与问题 (7) 的等价性可推广到反映用户公平性的其他系统效用函数。设 $u_{i_{k}}(\cdot)$ 为接收机 $i_{k}$ 数据速率（记为 $R_{i_{k}}$，见式 (2)）上的单调递增效用函数。考虑和效用最大化问题：
$$\begin{aligned} \max_{V} &\sum_{k=1}^{K}\sum_{i_{k}=1}^{I_{k}}u_{i_{k}}(R_{i_{k}}) \\ \text{s.t. } &\sum_{i=1}^{I_{k}}Tr(V_{i_{k}}V_{i_{k}}^{H})\le P_{k}, \quad k=1,2,...,K \quad \text{(10)} \end{aligned}$$

由经典关系 $R_{i_{k}}=\log\det((E_{i_{k}}^{mmse})^{-1})$ 可知，(10) 也可写为如下和 MSE 代价最小化问题：
$$\begin{aligned} \min_{V,U} &\sum_{k=1}^{K}\sum_{i=1}^{I_{k}}c_{i_{k}}(E_{i_{k}}) \\ \text{s.t. } &\sum_{i=1}^{I_{k}}Tr(V_{i_{k}}V_{i_{k}}^{H})\le P_{k}, \quad k=1,2,...,K \quad \text{(11)} \end{aligned}$$
其中 $E_{i_{k}}$ 见式 (3)，且
$c_{i_{k}}(E_{i_{k}})=-u_{i_{k}}(-\log\det(E_{i_{k}}))$。

类似定理 1，引入辅助权矩阵变量 $\{W_{i_{k}}\}_{i_{k}\in\mathcal{I}}$，定义矩阵加权和 MSE 最小化问题：
$$\begin{aligned} \min_{V,U,W} &\sum_{k=1}^{K}\sum_{i=1}^{I_{k}}(Tr(W_{i_{k}}^{H}E_{i_{k}})+c_{i_{k}}(\gamma_{i_{k}}(W_{i_{k}}))-Tr(W_{i_{k}}^{H}\gamma_{i_{k}}(W_{i_{k}}))) \\ \text{s.t. } &\sum_{i=1}^{I_{k}}Tr(V_{i_{k}}V_{i_{k}}^{H})\le P_{k}, \quad k=1,2,...,K \quad \text{(12)} \end{aligned}$$
其中 $\gamma_{i_{k}}(\cdot):\mathbb{R}^{d_{i_{k}}\times d_{i_{k}}}\mapsto\mathbb{R}^{d_{i_{k}}\times d_{i_{k}}}$ 是梯度映射 $\nabla c_{i_{k}}(E_{i_{k}})$ 的逆映射。

下述定理给出 (12) 与 (11) 等价的充分条件。

定理 2：若对所有 $i_{k}$，$c_{i_{k}}(\cdot)=-u_{i_{k}}(-\log\det(\cdot))$ 为严格凹函数，则逆梯度映射 $\gamma_{i_{k}}(\cdot)$ 良定义。并且对任意固定的收发波束形成器 $\{V,U\}$，(12) 的最优权矩阵满足
$W_{i_{k}}^{opt}=\nabla c_{i_{k}}(E_{i_{k}})$。
此外，和效用最大化问题 (10) 与矩阵加权和 MSE 最小化问题 (12) 等价，即二者具有相同全局最优解。

定理 2 的证明见附录 B。满足定理 2 条件的效用函数包括：加权和速率最大化、加权和 SINR 最大化、以及 $(1+\text{rate})$ 几何均值最大化等。特别地，对和速率效用、比例公平效用与调和平均速率效用，分别有
$u_{i_{k}}(R_{i_{k}})=\alpha_{i_{k}}R_{i_{k}}$、
$u_{i_{k}}(R_{i_{k}})=\log R_{i_{k}}$、
$u_{i_{k}}(R_{i_{k}})=-R_{i_{k}}^{-1}$。
可验证在这些情形下，$c_{i_{k}}(\cdot)=-u_{i_{k}}(-\log\det(\cdot))$ 均为严格凹函数，因此定理 2 适用。

---

## III. 用于和效用最大化的 WMMSE 算法
本节利用第 II 节（定理 1 与定理 2）建立的等价关系，为和效用最大化问题 (10) 设计一个简单的分布式 WMMSE 算法。为简化记号，先以和速率最大化问题 (1) 为主线介绍；随后再给出向一般和效用最大化的扩展。

由定理 1，只需求解等价的和 MSE 最小化问题 (7)。由于 (7) 的目标函数对各优化变量 $U$、$V$、$W$ 分别都是凸的，我们采用块坐标下降法。具体地，顺序固定三者中的两个并更新第三个，从而最小化加权和 MSE 代价。

权矩阵变量 $W_{i_{k}}$ 的更新有闭式解（见附录 A 的式 (19) 与式 (3)）：
$$W_{i_{k}}^{opt}=E_{i_{k}}^{-1} \quad \text{(13)}$$
接收波束形成器 $U_{i_{k}}$ 的更新由 MMSE 解 (5) 给出。

所有 $i_{k}$ 的发射波束形成器 $V_{i_{k}}$ 更新也可按发射机解耦，得到：
$$\begin{aligned} \min_{\{V_{i_{k}}\}_{i=1}^{I_{k}}} &\sum_{i=1}^{I_{k}}Tr(\alpha_{i_{k}}W_{i_{k}}(I-U_{i_{k}}^{H}H_{i_{k}k}V_{i_{k}})(I-U_{i_{k}}^{H}H_{i_{k}k}V_{i_{k}})^{H}) \\ \text{s.t. } &\sum_{i=1}^{I_{k}}Tr(V_{i_{k}}V_{i_{k}}^{H})\le P_{k}. [cite_start]\quad \text{(14)} \end{aligned}$$

这是一个凸二次优化问题，可用标准凸优化算法求解。事实上，通过拉格朗日乘子法可得闭式解。令 $\mu_{k}$ 为发射机 $k$ 功率约束对应的拉格朗日乘子，构造拉格朗日函数：
$$\begin{aligned} L(\{V_{i_{k}}\}_{i=1}^{I_{k}},\mu_{k}) \triangleq &\sum_{i=1}^{I_{k}}Tr(\alpha_{i_{k}}W_{i_{k}}(I-U_{i_{k}}^{H}H_{i_{k}k}V_{i_{k}})(I-U_{i_{k}}^{H}H_{i_{k}k}V_{i_{k}})^{H}) \\ &+ \sum_{i=1}^{I_{k}}\sum_{(l,j)\ne(i,k)}Tr(\alpha_{lj}W_{lj}U_{lj}^{H}H_{ljk}V_{i_{k}}V_{i_{k}}^{H}H_{ljk}^{H}U_{lj}^{H}) \\ &+ \mu_{k}\left(\sum_{i=1}^{I_{k}}Tr(V_{i_{k}}V_{i_{k}}^{H})-P_{k}\right). [cite_start]\end{aligned}$$

对每个 $V_{i_{k}}$ 的一阶最优条件给出：
$$V_{i_{k}}^{opt}=\left(\sum_{j=1}^{K}\sum_{l=1}^{I_{j}}\alpha_{lj}H_{ljk}^{H}U_{lj}W_{lj}U_{lj}^{H}H_{ljk}+\mu_{k}I\right)^{-1}\alpha_{i_{k}}H_{i_{k}k}^{H}U_{i_{k}}W_{i_{k}}, \quad i=1,...,I_{k} \quad \text{(15)}$$
其中 $\mu_{k}\ge0$ 需满足功率约束互补松弛条件。记式 (15) 右端为 $V_{i_{k}}(\mu_{k})$。

若矩阵
$\sum_{j=1}^{K}\sum_{l=1}^{I_{j}}\alpha_{lj}H_{ljk}^{H}U_{lj}W_{lj}U_{lj}^{H}H_{ljk}$
可逆，且
$\sum_{i=1}^{I_{k}}Tr(V_{i_{k}}(0)V_{i_{k}}(0)^{H})\le P_{k}$，
则 $V_{i_{k}}^{opt}=V_{i_{k}}(0)$；否则必须满足：
$$\sum_{i=1}^{I_{k}}Tr(V_{i_{k}}(\mu_{k})V_{i_{k}}(\mu_{k})^{H})=P_{k} \quad \text{(16)}$$
等价为：
$$Tr((\Lambda+\mu_{k}I)^{-2}\Phi)=P_{k} \quad \text{(17)}$$
其中，$D\Lambda D^{H}$ 是
$\sum_{j=1}^{K}\sum_{l=1}^{I_{j}}H_{l_{j}k}^{H}U_{l_{j}}W_{l_{j}}U_{l_{j}}^{H}H_{l_{j}k}$
的特征分解，
$\Phi=D^{H}\left(\sum_{i=1}^{I_{k}}\alpha_{i_{k}}^{2}H_{i_{k}k}^{H}U_{i_{k}}W_{i_{k}}^{2}U_{i_{k}}^{H}H_{i_{k}k}\right)D$。
令 $[X]_{mm}$ 表示矩阵 $X$ 的第 $m$ 个对角元素，则 (17) 化为：
$$\sum_{m=1}^{M_{k}}\frac{[\Phi]_{mm}}{([\Lambda]_{mm}+\mu_{k})^{2}}=P_{k}. [cite_start]\quad \text{(18)}$$

注意此时最优 $\mu_{k}$（记为 $\mu_{k}^{*}$）必为正，且 (18) 左端在 $\mu_{k}>0$ 时单调递减。因此可通过一维搜索（如二分法）高效求解。将 $\mu_{k}^{*}$ 代回 (15) 即得所有 $i=1,...,I_{k}$ 的 $V_{i_{k}}(\mu_{k}^{*})$。

MIMO-IBC 的 WMMSE 算法汇总于表 I。下述结果表明 WMMSE 必然收敛到 (1) 的一个驻点。

表 I  所提 MIMO-IBC WMMSE 算法伪代码
初始化 $V_{i_{k}}$，使得 $Tr(V_{i_{k}}V_{i_{k}}^{H})=\frac{P_{k}}{I_{k}}$
repeat
$\quad W_{i_{k}}^{\prime}\leftarrow W_{i_{k}}, \quad \forall i_{k}\in\mathcal{I}$
$\quad U_{i_{k}}\leftarrow\left(\sum_{(j,l)}H_{i_{k}j}V_{l_{j}}V_{l_{j}}^{H}H_{i_{k}j}^{H}+\sigma_{i_{k}}^{2}I\right)^{-1}H_{i_{k}k}V_{i_{k}}, \quad \forall i_{k}\in\mathcal{I}$
$\quad W_{i_{k}}\leftarrow(I-U_{i_{k}}^{H}H_{i_{k}k}V_{i_{k}})^{-1}, \quad \forall i_{k}\in\mathcal{I}$
$\quad V_{i_{k}}\leftarrow\alpha_{i_{k}}\left(\sum_{(j,l)}\alpha_{l_{j}}H_{l_{j}k}^{H}U_{l_{j}}W_{l_{j}}U_{l_{j}}^{H}H_{l_{j}k}+\mu_{k}I\right)^{-1}H_{i_{k}k}^{H}U_{i_{k}}W_{i_{k}}, \quad \forall i_{k}$
until $\left|\sum_{(j,l)}\log\det(W_{l_{j}})-\sum_{(j,l)}\log\det(W_{l_{j}}^{\prime})\right|\le\epsilon$

定理 3：WMMSE 算法生成迭代序列的任意极限点 $(W^{*},U^{*},V^{*})$ 都是 (7) 的驻点，相应的 $V^{*}$ 是 (1) 的驻点。反之，若 $V^{*}$ 是 (1) 的驻点，则由式 (13) 和式 (5) 定义的 $W_{i_{k}}^{*}$ 与 $U_{i_{k}}^{*}$，使得点 $(W^{*},U^{*},V^{*})$ 成为 (7) 的驻点。

定理 3 的证明见附录 C。需要指出，WMMSE 算法及其收敛性结果（定理 3）可扩展到一般和效用最大化问题 (10)。具体地，只需将表 I 中第 5 行替换为
$W_{i_{k}}\leftarrow \nabla c_{i_{k}}(E_{i_{k}})$，$\forall i_{k}$（见定理 2），
所得算法即可保证收敛到 (12) 与 (10) 的驻点。值得强调的是，一般和效用最大化下的 WMMSE 算法不需要显式知道逆梯度映射 $\gamma_{i_{k}}(\cdot)$，尽管 (12) 的定义中包含该映射。

---

## IV. 分布式实现与复杂度分析
为实现分布式计算，作出两条合理假设（与 [11] 类似）。第一，假设每个用户可获得本地信道状态信息，即每个发射机 $k$ 知道到所有接收机 $l_{j}$ 的本地信道矩阵 $H_{l_{j}k}$。第二，假设每个接收机具备一个附加反馈信道，可将更新信息（如更新后的波束形成器或等效信息）回传给发射机。在这两个假设下，WMMSE 算法可分布式实现。

更具体地，每个接收机 $i_{k}$ 本地估计接收信号协方差矩阵 $J_{i_{k}}$ 并更新 $U_{i_{k}}$、$W_{i_{k}}$；随后将更新后的 $W_{i_{k}}$ 与 $U_{i_{k}}$ 反馈给发射机。为降低通信开销，用户 $i_{k}$ 仅需反馈矩阵
$\alpha_{i_{k}}U_{i_{k}}W_{i_{k}}U_{i_{k}}^{H}$
的上三角部分，或反馈其分解 $\hat{U}_{i_{k}}$（满足 $\hat{U}_{i_{k}}\hat{U}_{i_{k}}^{H}=\alpha_{i_{k}}U_{i_{k}}W_{i_{k}}U_{i_{k}}^{H}$），具体取决于 $N_{i_{k}}$ 与 $d_{i_{k}}$ 的相对大小。需要指出的是，表 I 的终止准则可能不适于分布式实现。实践中建议设定最大迭代次数，或在每个数据包周期内仅执行一步算法。

需要注意，ILA 算法 [9], [12] 每次迭代只允许一个用户更新其发射协方差矩阵。某用户更新时，所有用户都需为其他用户计算 $(K-1)$ 个价格 [9] 或梯度矩阵 [12]，并在网络内广播。相比之下，WMMSE 在固定 $\{U,V,W\}$ 中任意两个变量时，更新步骤可按用户解耦，允许所有用户并行更新，因此 CSI 交换开销更低。

为简化复杂度分析，设 $\kappa\triangleq|\mathcal{I}|$ 为系统总用户数，$T$、$R$ 分别为每个发射机与接收机天线数。并且由于 WMMSE 与 ILA 都包含一般只需少量迭代的二分步骤，复杂度分析中忽略该步骤。

在这些假设下，ILA 每次迭代主要涉及 [12] 中价格矩阵（即 [12] 式 (10) 的 $A_{i}$）计算。为获得 ILA 价格矩阵，需先计算所有用户处干扰协方差并求和，每用户复杂度为 $\mathcal{O}(\kappa^{2})$。因此，ILA 的单次迭代复杂度为
$\mathcal{O}(\kappa^{3}T^{2}R+\kappa^{3}R^{2}T+\kappa^{2}R^{3})$。
类似分析可得 WMMSE 的单次迭代复杂度为
$\mathcal{O}(\kappa^{2}TR^{2}+\kappa^{2}RT^{2}+\kappa^{2}T^{3}+\kappa R^{3})$。
这里“一次迭代”指 WMMSE 或 ILA 对所有用户波束形成器/协方差矩阵完成一轮更新。

---

## V. 仿真结果
本节通过数值实验评估所提 WMMSE 算法性能。为便于与现有算法比较，全部仿真均在 MIMO 干扰信道场景下进行（即每小区一个接收机的退化 MIMO-IBC）。所有用户的权重 $\{\alpha_{i_{k}}\}$ 与噪声功率 $\{\sigma_{i_{k}}^{2}\}$ 设为相同。所有发射机功率预算均设为 $P$，其中 $P=10^{\frac{SNR}{10}}$。此外，所有发射机（或接收机）假设具有相同天线数，分别记为 $T$（或 $R$）。信道采用非相关衰落模型，信道系数由复高斯分布 $\mathcal{CN}(0,1)$ 生成。

图 1(a)、(b) 展示了 $SNR=25$ dB 时 WMMSE 的收敛行为。结果表明 WMMSE 在较少步数内收敛，且收敛过程单调。

图 2 给出了 SISO 干扰信道下平均和速率随 SNR 的变化。每条曲线对 100 次随机信道实现取平均。术语 “WMMSE” 表示运行一次 WMMSE；“WMMSE_10rand_int” 表示使用不同初始化运行 10 次并取最优结果。“ILA” 与 “ILA_10rand_int” 定义类似。可见 WMMSE 与 ILA 性能几乎一致。三用户情形下还给出了暴力搜索（指数复杂度）作为基准。可以看到 WMMSE 与最优性能之间差距较小，且随 SNR 增加缓慢扩大；而将 WMMSE 重复运行 10 次可缩小该差距。

MIMO 干扰信道下也有类似结论，如图 3 所示。作为对比，还给出了 MMSE 算法 [21] 的性能（已有研究表明其优于干扰对齐方法 [22]）。显然，WMMSE 在可达和速率上显著优于 MMSE，原因在于采用了迭代权矩阵 $W$。

尽管 ILA 在和速率性能上与 WMMSE 几乎相同，但其复杂度更高。图 4 在相同终止准则下比较了两者平均 CPU 时间。可见当用户数较大时，WMMSE 相比 ILA 具有显著优势。

---

## VI. 总结
协同波束形成是蜂窝通信系统中抑制干扰的重要信号处理技术。许多线性收发器设计问题都可表述为和效用最大化问题。通过引入权矩阵变量，本文将 MIMO-IBC 的和效用最大化问题转化为等价的和 MSE 代价最小化问题。后者可由简单的分布式块坐标下降策略高效求解，即本文提出的 WMMSE 方法。该方法单次迭代复杂度低，并可保证收敛到原和效用最大化问题的驻点。

WMMSE 方法具有很强通用性，可用于广泛的和效用最大化问题，包括和速率最大化、$(1+\text{rate})$ 调和均值最大化、和 SINR 最大化、和 MSE 最小化等。计算机仿真表明，WMMSE 在协同波束形成和干扰对齐任务中，相比现有方法在性能与计算效率上均有显著提升。我们预计 WMMSE 在其他应用场景中也将是有效工具，例如 DSL 网络动态频谱管理，以及无线网络分布式功率控制。

---

## 附录 A
### 定理 1 的证明

定理 1 证明：首先可知，最小化 (7) 时的最优 $U_{i_k}$ 由式 (5) 给出。进一步地，固定 $U_{i_k}^{mmse}$ 和其余变量后，(7) 的目标函数关于 $W_{i_k}$ 是凸的。因此由 $W_{i_k}$ 的一阶最优条件得到：
$$W_{i_k}^{opt}=E_{i_k}^{-1} \quad \text{(19)}$$
将所有 $i_k\in\mathcal{I}$ 的最优 $U_{i_k}$ 与 $W_{i_k}$ 代回 (7)，可得等价问题：
$$\begin{aligned} \max_{\{V\}} &\sum_{k=1}^{K}\sum_{i=1}^{I_k}\alpha_{i_k}\log\det((E_{i_k}^{mmse})^{-1}) \\ \text{s.t. } &Tr(V_{i_k}V_{i_k}^H)\le P_k,\quad \forall i_k\in\mathcal{I}. [cite_start]\quad \text{(20)} \end{aligned}$$
定义
$\Upsilon_{i_k}\triangleq\sum_{(l,j)\ne(i,k)}H_{i_k j}V_{l_j}V_{l_j}^H H_{i_k j}^H+\sigma_{i_k}^2 I$，
则有：
$$\begin{aligned} \log\det((E_{i_k}^{mmse})^{-1}) &= \log\det(I+V_{i_k}^H H_{i_k k}^H \Upsilon_{i_k}^{-1}H_{i_k k}V_{i_k}) \\ &= \log\det(I+H_{i_k k}V_{i_k}V_{i_k}^H H_{i_k k}^H \Upsilon_{i_k}^{-1}) \quad \text{(21)} \end{aligned}$$
第一步等号由对式 (6) 使用 Woodbury 矩阵恒等式得到；第二步等号利用 $\det(I+A_1 A_2)=\det(I+A_2 A_1)$。结合 (21) 与 (20) 即完成证明。

## 附录 B
### 定理 2 的证明
证明：为简化记号，省略下标 $i_{k}$。此处 $W$ 表示 $W_{i_{k}}$。首先证明 $\nabla c(E)$ 是可逆映射，从而其逆映射 $\gamma(\cdot)$ 良定义。反设不成立，即存在两个不同 MSE 值 $E_{1}$、$E_{2}$ 使得 $\nabla c(E_{1})=\nabla c(E_{2})$。由于 $c(\cdot)$ 严格凹，有：
$$\begin{aligned} c(E_{1}) &< c(E_{2}) + Tr((\nabla c(E_{2}))^{H}(E_{1}-E_{2})), \\ c(E_{2}) &< c(E_{1}) + Tr((\nabla c(E_{1}))^{H}(E_{2}-E_{1})). \end{aligned}$$
两式相加立即导出矛盾。

接着证明
$g(W)\triangleq c(\gamma(W))-Tr(W^{H}\gamma(W))$
严格凸。先计算 $g(\cdot)$ 的梯度：
$$\begin{aligned} \nabla g(W) &= \sum_{i,j}\frac{\partial c}{\partial\gamma_{i,j}}\nabla\gamma_{i,j}(W)-\nabla_{W}\left(\sum_{i,j}W_{i,j}\gamma_{i,j}(W)\right) \\ &= \sum_{i,j}\frac{\partial c}{\partial\gamma_{i,j}}\nabla\gamma_{i,j}(W)-\sum_{i,j}\nabla(W_{i,j})\gamma_{i,j}(W)-\sum_{i,j}W_{i,j}\nabla\gamma_{i,j}(W) \\ &= \sum_{i,j}W_{i,j}\nabla\gamma_{i,j}(W)-\sum_{i,j}1_{i,j}\gamma_{i,j}(W)-\sum_{i,j}W_{i,j}\nabla\gamma_{i,j}(W) \\ &= -\gamma(W) \quad \text{(22)} \end{aligned}$$
其中 $X_{i,j}$ 表示矩阵 $X$ 的 $(i,j)$ 元素，$1_{i,j}$ 表示仅在 $(i,j)$ 位置为 1、其余为 0 的矩阵。

对任意固定点 $W$ 与任意可行方向 $Z$，定义 $q(t;W,Z)=g(W+tZ)$。为证明 $g(\cdot)$ 严格凸，只需验证对任意固定 $W,Z$，$q(t;W,Z)$ 关于 $t$ 严格凸。根据定义可得（23），其中不等号来自 $c(\cdot)$ 的严格凹性：
$$\begin{aligned} q(t_{2};W,Z) &= g(W+t_{2}Z) \\ &= c(\gamma(W+t_{2}Z))-Tr((W+t_{2}Z)^{H}\gamma(W+t_{2}Z)) \\ &> c(\gamma(W+t_{1}Z))-Tr((\nabla c(\gamma(W+t_{2}Z)))^{H}(\gamma(W+t_{1}Z)-\gamma(W+t_{2}Z)))-Tr((W+t_{2}Z)^{H}\gamma(W+t_{2}Z)) \\ &= c(\gamma(W+t_{1}Z))-Tr((W+t_{2}Z)^{H}(\gamma(W+t_{1}Z)-\gamma(W+t_{2}Z)))-Tr((W+t_{2}Z)^{H}\gamma(W+t_{2}Z)) \\ &= c(\gamma(W+t_{1}Z))-Tr((W+t_{2}Z)^{H}\gamma(W+t_{1}Z)) \\ &= c(\gamma(W+t_{1}Z))-Tr((W+t_{1}Z)^{H}\gamma(W+t_{1}Z))-(t_{2}-t_{1})Tr(Z^{H}\gamma(W+t_{1}Z)) \\ &= g(W+t_{1}Z)+Tr(Z^{H}\nabla g(W+t_{1}Z))(t_{2}-t_{1}) \\ &= q(t_{1};W,Z)+q'(t_{1};W,Z)\cdot(t_{2}-t_{1}) \quad \text{(23)} \end{aligned}$$
由此可见 $q(t;W,Z)$ 关于 $t$ 严格凸。由于任意固定 $W,Z$ 下 $q(\cdot;W,Z)$ 均严格凸，故 $g(W)$ 严格凸。

因此，(12) 的目标函数关于 $W$ 严格凸。由 (22) 得到
$E_{i_{k}}-\gamma(W_{i_{k}}^{opt})=0$，
从而对所有 $i_{k}$ 有
$W_{i_{k}}^{opt}=\nabla c_{i_{k}}(E_{i_{k}})$。
将该最优 $W$ 代回 (12)，即得 (12) 与 (11) 的等价性。

## 附录 C
### 定理 3 的证明
证明：优化问题 (7) 的目标函数可微，且约束集合在变量 $W$、$U$、$V$ 上是可分的。由一般优化理论 [23] 可知，作为对 (7) 应用块坐标下降法得到的 WMMSE 算法收敛到 (7) 的一个驻点。接下来只需验证：$V^{*}$ 是 (1) 的驻点，当且仅当存在某些 $W^{*}$ 与 $U^{*}$，使得 $(W^{*},U^{*},V^{*})$ 是 (7) 的驻点。定义：
$$\begin{aligned} \psi_{1}(W,U,V) &\triangleq \sum_{k=1}^{K}\sum_{i=1}^{I_{k}}\alpha_{i_{k}}(Tr(W_{i_{k}}E_{i_{k}})-\log\det(W_{i_{k}})) \\ \psi_{2}(V) &\triangleq \sum_{k=1}^{K}\sum_{i=1}^{I_{k}}\alpha_{i_{k}}\log\det(E_{i_{k}}^{mmse}) \end{aligned}$$
由于 $(W^{*},U^{*},V^{*})$ 是 (7) 的驻点，且 (7) 的约束为笛卡尔积形式，因此有：
$$Tr(\nabla_{U_{i_{k}}}\psi_{1}(W^{*},U^{*},V^{*})^{H}(U_{i_{k}}-U_{i_{k}}^{*}))\le0, \quad \forall U_{i_{k}}, \forall i_{k} \quad \text{(24)}$$
$$Tr(\nabla_{W_{i_{k}}}\psi_{1}(W^{*},U^{*},V^{*})^{H}(W_{i_{k}}-W_{i_{k}}^{*}))\le0, \quad \forall W_{i_{k}}, \forall i_{k} \quad \text{(25)}$$
$$Tr(\nabla_{V}\psi_{1}(W^{*},U^{*},V^{*})^{H}(V-V^{*}))\le0, \quad \forall V\in\mathbb{S} \quad \text{(26)}$$
其中 $\mathbb{S}=\{V|\sum_{i=1}^{I_{k}}Tr(V_{i_{k}}V_{i_{k}}^{H})\le P_{k},\forall k\}$ 为可行集。由于 (24) 与 (25) 必须对任意（无约束的）$W_{i_{k}}$ 与 $U_{i_{k}}$ 成立，得到：
$$U_{i_{k}}^{*} = U_{i_{k}}^{mmse} \quad \text{and} \quad W_{i_{k}}^{*} = (E_{i_{k}}^{mmse})^{-1} \quad \text{(27)}$$
令 $v_{l_{j},mn}$ 表示 $V_{l_{j}}$ 的第 $(m,n)$ 个元素。由链式法则可得：
$$\begin{aligned} \frac{\partial\psi_{1}(W^{*},U^{*},V^{*})}{\partial v_{l_{j},mn}} &= \sum_{k=1}^{K}\sum_{i=1}^{I_{k}}\alpha_{i_{k}}Tr\left(W_{i_{k}}^{*}\frac{\partial E_{i_{k}}(U^{*},V^{*})}{\partial v_{l_{j},mn}}\right) \\ &= \sum_{k=1}^{K}\sum_{i=1}^{I_{k}}\alpha_{i_{k}}Tr\left((E_{i_{k}}^{mmse})^{-1}\frac{\partial E_{i_{k}}^{mmse}(V^{*})}{\partial v_{l_{j},mn}}\right) \\ &= \frac{\partial\psi_{2}(V^{*})}{\partial v_{l_{j},mn}} \end{aligned}$$
其中第一与第三个等号由链式法则得到，第二个等号由 (27) 得到。于是由 (26) 有：
$$Tr(\nabla_{V}\psi_{2}(V^{*})^{H}(V-V^{*})) = Tr(\nabla_{V}\psi_{1}(W^{*},U^{*},V^{*})^{H}(V-V^{*})) \le 0$$
这正是 $V^{*}$ 关于问题 (1) 的驻点条件。反向结论可通过逆向上述证明步骤得到。

---

## 参考文献
[1] Z.-Q. Luo and S. Zhang, "Dynamic spectrum management: complexity and duality," IEEE J. Sel. Topics Signal Process., vol. 2, no. 1, pp. 57-73, Feb. 2008.

[2] S. Ye and R. S. Blum, "Optimized signaling for MIMO interference systems with feedback," IEEE Trans. Signal Process., vol. 51, no. 11, pp. 2839-2848, Nov. 2003.

[3] E. Larsson and E. Jorswieck, "Competition versus cooperation on the MISO interference channel," IEEE J. Sel. Areas Commun., vol. 26, no. 7, pp. 1059-1069, Sep. 2008.

[4] E. A. Jorswieck and E. G. Larsson, "The MISO interference channel from a game-theoretic perspective: a combination of selfishness and altruism achieves Pareto optimality," presented at the IEEE Int. Conf. Acoust., Speech, Signal Process. (ICASSP), Las Vegas, NV, Apr. 2008.

[5] C. Shi, R. A. Berry, and M. L. Honig, "Distributed interference pricing with MISO channels," presented at the Allerton Conf. Commun., Control, Comput., Urbana-Champaign, IL, Sep. 2008.

[6] J. Huang, R. A. Berry, and M. L. Honig, "Distributed interference compensation for wireless networks," IEEE J. Sel. Areas Commun., vol. 24, no. 5, pp. 1074-1084, May 2006.

[7] Z.-Q. Luo and J. S. Pang, "Analysis of iterative waterfilling algorithm for multiuser power control in digital subscriber lines," EURASIP J. Appl. Signal Process., vol. 2006, no. 1, pp. 1-10, Jan. 2006.

[8] G. Scutari, D. P. Palomar, and S. Barbarossa, "The MIMO iterative waterfilling algorithm," IEEE Trans. Signal Process., vol. 57, no. 5, pp. 1917-1935, May 2009.

[9] C. Shi. R. A. Berry, and M. L. Honig, "Monotonic convergence of distributed interference pricing in wireless networks," presented at the IEEE Int. Symp. Inf. Theory (ISIT), Seoul, Korea, Jun. 2009.

[10] C. Shi, R. A. Berry, and M. L. Honig, "Local interference pricing for distributed beamforming in MIMO networks," presented at the IEEE MILCOM, Boston, MA, Oct. 2009.

[11] Z. K. M. Ho and D. Gesbert, "Balancing egoism and altruism on interference channel: The MIMO case," presented at the IEEE ICC, Cape Town, South Africa, May 2010.

[12] S. J. Kim and G. B. Giannakis, "Optimal resource allocation for MIMO ad hoc cognitive radio networks," presented at the Allerton Conf. Commun., Control, Comput., Urbana-Champaign, IL, Sep. 2008.

[13] S. S. Christensen, R. Argawal, E. de Carvalho, and J. M. Cioffi, "Weighted sum-rate maximization using weighted MMSE for MIMO-BC beamforming design," IEEE Trans. Wireless Commun., vol. 7, no. 12, pp. 1-7, Dec. 2008.

[14] D. Schmidt, C. Shi, R. A. Berry, M. L. Honig, and W. Utschick, "Minimum mean squared error interference alignment," presented at the Asilomar Conf. Signals, Syst., Comput., Pacific Grove, CA, Nov. 2009.

[15] D. Bertsekas. Nonlinear Programming, 2nd ed. Belmont, MA: Athena Scientific, 1999.

[16] R. Tresh and M. Guillaud, "Cellular interference alignment with imperfect channel knowledge." presented at the IEEE Int. Conf. Commun. (ICC), Dresden, Germany, Jun. 2009.

[17] D. Shiu, G. J. Foschini, M. J. Gans, and J. M. Kahn, "Fading correlation and its effect on the capacity of multielement antenna systems," IEEE Trans. Commun., vol. 48, no. 3, pp. 502-513, Mar. 2000.

[18] S. Serbetli and A. Yener, "MMSE transmitter design for correlated MIMO systems with imperfect channel estimates: power allocation trade-offs." IEEE Trans. Wireless Commun., vol. 5, no. 8, pp. 2295-2304, Aug. 2006.

[19] M. Ding and S. D. Blostein, "MIMO minimum total MSE transceiver design with imperfect CSI at both ends," IEEE Trans. Signal Process., vol. 57, no. 3, pp. 1141-1150, Mar. 2009.

[20] M. Medard, "The effect upon channel capacity in wireless communications of perfect and imperfect knowledge of the channel," IEEE Trans. Inf. Theory, vol. 46, no. 3, pp. 933-946, May 2000.

[21] M. Razaviyayn, M. S. Boroujeni, and Z.-Q. Luo, "Linear transceiver design for interference alignment: Complexity and computation," presented at the IEEE Signal Process. Adv. in Wireless Commun. (SPAWC), Marrakech, Morocco, Jun. 2010.

[22] K. Gomadam, V. R. Cadambe, and S. A. Jafar, "Approaching the capacity of wireless networks through distributed interference alignment," presented at the IEEE GLOBECOM, Miami, FL, Dec. 2008.

[23] M. V. Solodov, "On the convergence of constrained parallel variable distribution algorithm," SIAM J. Optim., vol. 8, no. 1, pp. 187-196, Feb. 1998.
