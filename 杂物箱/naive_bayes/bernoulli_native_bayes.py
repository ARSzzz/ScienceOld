"""
伯努利贝叶斯

"""

from model import Model
from multiprocessing import Pool, cpu_count


def main():
    """pass"""
    process_pool = Pool(cpu_count())
    self = Model(process_pool)
    # self.param_initializer()
    self.new_model()

    # batch = next(self.iter_obj)
    # _ = self.gen_train_pair(batch)

    print('top 1 : ', self.score(1))
    print('top 5 : ', self.score(5))
    print('top 10: ', self.score(10))


if __name__ == '__main__':
    main()
