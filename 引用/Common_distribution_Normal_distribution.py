from scipy.stats import norm
import matplotlib.pyplot as plt
import numpy as np

# pylint: disable=W1401

# 设定图形的尺寸
plt.figure(figsize=(8, 4))
x = np.linspace(-5, 5, 1000)

plt.plot(x, norm.pdf(x, -2, 1), lw=3, alpha=0.7,
         label='$\mu=-2, \sigma=1$')

plt.plot(x, norm.pdf(x, 0, 1), lw=3, alpha=0.7,
         label='$\mu=0, \sigma=1$')

plt.plot(x, norm.pdf(x, 0, 0.5), lw=3, alpha=0.7,
         label='$\mu=0, \sigma=0.5$')

plt.plot(x, norm.pdf(x, 0, 1.5), lw=3, alpha=0.7,
         label='$\mu=0, \sigma=1.5$')

plt.xlabel('$x$')
plt.ylabel(r'$\varphi_{\mu, \sigma^2}(x)$')
plt.legend(loc=1)

plt.savefig('Common_distribution_Normal_distribution.svg')
