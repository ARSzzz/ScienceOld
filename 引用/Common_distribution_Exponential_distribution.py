from scipy.stats import expon
import numpy as np
import matplotlib.pyplot as plt


def plot_exponential_distribution(x, _lambda):
    scale = 1 / _lambda
    plt.plot(
        x,
        expon.pdf(x, scale=scale),
        lw=3,
        alpha=0.7,
        label='$\lambda$ = %s' % _lambda
    )

plt.figure(figsize=(8, 4))
x = np.linspace(0, 5, 1000)
plot_exponential_distribution(x, 0.5)
plot_exponential_distribution(x, 1)
plot_exponential_distribution(x, 3)


plt.xlabel('$x$')
plt.ylabel('$p(x)$')
plt.legend(loc=1)

plt.savefig('Common_distribution_Exponential_distribution.svg')
