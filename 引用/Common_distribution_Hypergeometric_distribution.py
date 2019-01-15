from scipy.stats import hypergeom
import matplotlib.pyplot as plt
import numpy as np


def plot_hypergeom(M, N, n):
    x1 = range(min(n, N)+1)
    x2 = range(n+1)
    plt.plot(
        x1,
        hypergeom(M=M, n=n, N=N).pmf(x1),
        alpha=0.6,
        color='gray'
    )
    plt.plot(
        x2,
        hypergeom(M=M, n=n, N=N).pmf(x2),
        'o',
        label='$n={0},N={1},M={2}$'.format(N, M, n)
    )


# 设定图形的尺寸
plt.figure(figsize=(8, 4))

# ====================
# scipy N = n
# scipy M = N
# scipy n = M
# =====================
[N, M, n] = [180, 300, 40]
plot_hypergeom(M=M, N=N, n=n)


[N, M, n] = [120, 300, 36]
plot_hypergeom(M=M, N=N, n=n)


[N, M, n] = [60, 300, 30]
plot_hypergeom(M=M, N=N, n=n)


plt.xlabel('$k$ values')
plt.ylabel('$P(X=k)$')
plt.legend(loc=1)

plt.savefig('Common_distribution_Hypergeometric_distribution.svg')
