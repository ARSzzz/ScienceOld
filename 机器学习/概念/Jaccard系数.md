# Jaccard 系数 Jaccard index

## 一、概述 Overview

Jaccard 系数（`Jaccard index`）又称 `Intersection over Union` 或 Jaccard 相似系数（`Jaccard similarity coefficient`），用于比较有限样本集之间的相似性与差异性。Jaccard 系数值越大，样本相似度越高。

> **定义：Jaccard 系数 Jaccard index**
> 设 $A$ 和 $B$ 为两个非空有限样本集。定义函数 $\mathrm{J}(\cdot)$ 来度量两个集合之间的相似性，称之为 Jaccard 系数。集合 $A$ 与 $B$ 之间的 Jaccard 系数定义如下：
> $$\mathrm{J}(A, B)=\frac{|A \bigcap B|}{|A \bigcup B|}
> =\frac{|A \bigcap B|}{|A| + |B| -|A \bigcap B|},
> \quad \mathrm{J}(A,B) \in [0,1]$$

注意：*如果 $A$ 和 $B$ 均为 $\varnothing$，定义 $J(A, B)=1$。*

> **定义：Jaccard 距离 Jaccard distance**
> 设 $A$ 和 $B$ 为两个非空有限样本集。由 Jaccard 系数引申出指标 $\mathrm{d}_J(\cdot)$ 来度量两个集合之间的距离，称之为**Jaccard 距离**。集合 $A$ 与 $B$ 之间的 Jaccard 距离定义如下：
> $$\mathrm{d}_J(A, B)=1-\mathrm{J}(A, B)
> =\frac{|A \bigcup B|-|A \bigcap B|}{|A \bigcup B|}$$

## 二、不对称二元变量的相似性 Similarity of asymmetric binary variable

设有 $n$ 维不对称二元变量 $X$。$X$ 的 $n$ 个维度代表 $n$ 个属性的测量，其取值为 $\{0,1\}$。$x_a$ 和 $x_b$ 是 $X$ 的两个样本，它们的 $n$ 个属性的**所有可能**的对应情况列示如下：

|           | $x_a=0$    | $x_a=1$    |
| --------- | -------- | -------- |
| **$x_b=0$** | $M_{00}$ | $M_{10}$ |
| **$x_b=1$** | $M_{01}$ | $M_{11}$ |

上表中，$\{M_{00}, M_{10}, M_{01}, M_{11}\}$ 是每种对应情况的计数。因此有：

$$M_{00} + M_{10} + M_{01} + M_{11}=n$$

可以将随机变量 $X$ 的任意样本 $x_i$ 的 $n$ 个维度的取值视为样本是否包含对应的属性，其取值为 $1$ 时表示包含，其取值为 $0$ 时表示不包含。因此可以将样本 $x_a$ 看作一个集合 $A$，$A$ 里面的元素是样本中取值为 $1$ 的属性。同理可由 $x_b$ 得到 $B$。基于此，可以用 Jaccard 系数通过 $\{A,B\}$ 来度量 ${x_a, x_b}$ 的相似性。

$$\begin{cases}
    \mathrm{J}(A, B) &= \frac{M_{11}}{M_{10} + M_{01} + M_{11}}\\
\mathrm{d}_J(A,B)    &= 1-\mathrm{J}(A, B)=\frac{M_{10} + M_{01}}{M_{10} + M_{01} + M_{11}}
\end{cases}
$$

Jaccard 系数的这种用法与**简单匹配系数**（`Simple matching coefficient`, SMC）很相似，其区别是：SMC 在计算中，分子和分母会包括 $M_{00}$ 系数，但 Jaccard 系数不会。

## 三、广义 Jaccard 相似度与距离 Generalized Jaccard similarity and distance

设随机变量 $X=\{x_1, x_2, \dots, x_n\},\ \min(X) \geq 0$。$\{a, b\}$ 是 $X$ 的两个样本，则其 Jaccard 相似度（`Jaccard similarity`）或 `Ruzicka similarity` 是：
$$\mathrm{J}(a, b)=\frac{\sum_{i=1}^n \min(a_i, b_i)}{\sum_{i=1}^n \max(a_i, b_i)}$$

同时，Jaccard 距离（`Jaccard distance`）或 `Soergel distance` 是：
$$\mathrm{D}_J(a, b)=1-\mathrm{J}(a,b)$$

原文：*With even more generality, if $f$ and $g$ are two non-negative `measurable functions` on a `measurable space` $X$ with measure \mu , then we can define*
$$\mathrm{J}(f,g)=\frac{\int\min(f,g)\mathrm{d}\mu}{\int\max(f,g)\mathrm{d}\mu}$$

原文：*where $\max$ and $\min$ are pointwise operators. Then Jaccard distance is*
$$\mathrm{d}_J(f,g)=1-\mathrm{J}(f,g)$$

原文：*Then, for example, for two measurable sets $A,B \subseteq X$, we have $J_{\mu }(A,B)=J(\chi_{A},\chi_{B})$, where $\chi_{A}$ and $\chi_{B}$ are the characteristic functions of the corresponding set.*
