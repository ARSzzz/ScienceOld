# Rosenblatt 感知机

**感知机是第一个从算法上完整描述的神经网络**。Rosenblatt 感知机是最先出现的作为监督学习的感知机模型。

## 结构

Rosenblatt 感知机建立在一个非线性的神经元上，即 McCulloch-Pitts[^McCulloch-Pitts] 神经元，以解决**线性可分**的两分类问题。

@import "../引用/Rosenblatt_perceptron.png"

- 突触权值: $(w_1, w_2, \cdots, w_m)$

- 激活函数：硬限幅器 $\varphi(\cdot)$ 函数。输入为正时，神经元输出 $+1$，输入为负时，神经元输出 $-1$。

- 输入信号：$(x_1, x_2, \cdots, x_m)$

- 响应器

感知机的目的是把外部作用刺激即输入信号 $(x_1, x_2, \cdots, x_m)$ 正确分类为 $\mathcal{C}_1$ 和 $\mathcal{C}_2$ 两类。

$$v = \sum_{i=1}^mw_ix_i + b$$

$$y = \varphi(v)$$

[^McCulloch-Pitts]: 激活函数为阈值函数的神经元也被称为 McCulloch-Pitts 神经元。