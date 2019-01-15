from scipy.stats import beta
import matplotlib.pyplot as plt
import numpy as np


def plot_beta_distribution(a, b):
    x = np.linspace(0, 1, 1000)
    y = beta.pdf(x, a=a, b=b)
    plt.plot(x, y, lw=3, alpha=0.7,
    label = 'a=%s, b=%s' % (a, b))

plt.figure(figsize=(8, 4))

plot_beta_distribution(0.8, 0.8)
plot_beta_distribution(1.6, 1.6)
plot_beta_distribution(0.8, 1.6)
plot_beta_distribution(1.6, 0.8)
plot_beta_distribution(1, 1)


plt.xlabel(r'$x$')
plt.ylabel(r'$p(x)$')
plt.legend(loc=1)

plt.savefig('Common_distribution_Beta_distribution.svg')
