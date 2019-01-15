from scipy.stats import nbinom
import matplotlib.pyplot as plt
import numpy as np


def plot_nbinom(r, p):
    left  = nbinom.ppf(0.01, r, p)
    right = nbinom.ppf(0.99, r, p)
    x = np.arange(
        left,
        right,
        int((right - left) / 10)
    )
    plt.plot(
        x,
        nbinom.pmf(x, r, p),
        alpha=0.6,
        color='gray'
    )
    plt.plot(
        x,
        nbinom.pmf(x, r, p),
        'o',
        label='$r=%s, p = %s$' % (r, p)
    )


plt.figure(figsize=(8,4))

r, p = 1, 0.2
plot_nbinom(r, p)

r, p = 2, 0.2
plot_nbinom(r, p)

r, p = 5, 0.2
plot_nbinom(r, p)

plt.xlabel('$k$ values')
plt.ylabel('$P(X=k)$')
plt.legend(loc=1)
plt.savefig(
    'Common_distribution_Negative_binomial_distribution_1.svg'
)

plt.figure(figsize=(8,4))

r, p = 2, 0.1
plot_nbinom(r, p)

r, p = 2, 0.2
plot_nbinom(r, p)

r, p = 2, 0.4
plot_nbinom(r, p)

plt.xlabel('$k$ values')
plt.ylabel('$P(X=k)$')
plt.legend(loc=1)

plt.savefig(
    'Common_distribution_Negative_binomial_distribution_2.svg'
)
