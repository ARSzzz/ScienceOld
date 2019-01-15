from scipy.stats import poisson
import matplotlib.pyplot as plt

# pylint: disable=W1401


def plot_poisson(n, _lambda):
    plt.plot(range(n+1), poisson.pmf(range(n+1), _lambda),
             alpha=0.6, color='gray')
    plt.plot(range(n+1), poisson.pmf(range(n+1), _lambda),
             'o', label='$\lambda = {}$'.format(_lambda))

# 设定图形的尺寸
plt.figure(figsize=(8, 4))
n = 20  # X的显示范围为[0, 20]

_lambda = 1
plot_poisson(n, _lambda)

_lambda = 4
plot_poisson(n, _lambda)

_lambda = 7
plot_poisson(n, _lambda)

plt.xlabel('$k$ values')
plt.ylabel('$P(X=k)$')
plt.legend(loc=1)
plt.xticks([0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20])

plt.savefig('Common_distribution_Poisson_distribution.svg')
