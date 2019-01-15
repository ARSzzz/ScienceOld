from scipy.stats import binom
import matplotlib.pyplot as plt
import numpy as np
from math import ceil


def plot_binomial(n, p):
    x = np.arange(
        0,
        n,
        1
    )
    plt.plot(x, binom.pmf(x, n, p),
             alpha=0.6, color='gray')
    plt.plot(x, binom.pmf(x, n, p),
             'o', label='$n={0}, p={1}$'.format(n, p))


# 设定图形的尺寸
plt.figure(figsize=(8, 4))

n, p = 20, 0.5
plot_binomial(n, p)

n, p = 20, 0.7
plot_binomial(n, p)

n, p = 40, 0.5
plot_binomial(n, p)

plt.xlabel('$k$ values')
plt.ylabel('$P(X=k)$')
plt.legend(loc=1)

plt.savefig('Common_distribution_Binomial_distribution.svg')
