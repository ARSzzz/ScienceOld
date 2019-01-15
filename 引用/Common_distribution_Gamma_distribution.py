from math import gamma, e
import numpy as np
import matplotlib.pyplot as plt


def gamma_distribution_pdf(x, _alpha, _lambda):
    if x < 0:
        return 0
    numerator = (_lambda ** _alpha) * (x ** (_alpha-1)) * (e ** (-_lambda*x))
    denominator = gamma(_alpha)
    return numerator / denominator


def plot_gamma_distribution(_alpha, _lambda):
    x = np.linspace(0, 10, 1000)
    y = [
        gamma_distribution_pdf(item, _alpha, _lambda)
        for item in x
    ]
    plt.plot(x, y, lw=3, alpha=0.7,
             label=r'$\alpha$ = %s, $\lambda$ = %s' % (_alpha, _lambda))

# 设定图形的尺寸
plt.figure(figsize=(8, 4))

plot_gamma_distribution(0.9, 2)
plot_gamma_distribution(1, 2)
plot_gamma_distribution(3, 2)
plot_gamma_distribution(3, 1)

plt.xlabel('$x$')
plt.ylabel('p(x)')
plt.legend(loc=1)

plt.savefig('Common_distribution_Gamma_distribution.svg')
