from scipy.stats import geom
import matplotlib.pyplot as plt


def plot_geom(n, p):
    plt.plot(
        range(1, n+1),
        geom.pmf(range(1, n+1), p),
        alpha=0.6,
        color='gray'
    )
    plt.plot(
        range(1, n+1),
        geom.pmf(range(1, n+1), p),
        'o',
        label='$p = %s$' % p
    )

# 设定图形的尺寸
plt.figure(figsize=(8, 4))
n = 10  # X的显示范围为[0, 10]

p = 0.2
plot_geom(n, p)

p = 0.5
plot_geom(n, p)

p = 0.8
plot_geom(n, p)

plt.xlabel('$k$ values')
plt.ylabel('$P(X=k)$')
plt.legend(loc=1)
plt.xticks(range(1, n+1))

plt.savefig('Common_distribution_Geometric_distribution.svg')
