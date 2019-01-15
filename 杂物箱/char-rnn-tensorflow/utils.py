"""
utils for rnn tensorflow
用于数据预处理的工具脚本
"""

import codecs
import os
import collections
from six.moves import cPickle
import numpy as np


class TextLoader():
    """pass
    """

    def __init__(self, data_dir, batch_size, seq_length, encoding='utf-8'):
        """
        导入文件

        parameter
        ---------
        data_dir : 目标文件夹。内有：input.txt，vocab.pkl，data.npy

        batch_size : 批量的尺寸。

        seq_length : pass。

        encoding : input.txt的文件编码。

        """
        # 初始化
        # 
        self.batch_size = None      # 批量的尺寸
        self.chars = None           # 字符集合
        self.data_dir = None        # 文件目录
        self.encoding = None        # 文本编码种类
        self.num_batches = None     # 批量数
        self.pointer = None         # batch指示点
        self.seq_length = None      # pass
        self.tensor = None          # 用编码表示的文本
        self.vocab = None           # 编码字典
        self.vocab_size = None      # 编码数量
        self.x_batches = None       # x的批量包
        self.y_batches = None       # y的批量包

        self.data_dir = data_dir
        self.batch_size = batch_size
        self.seq_length = seq_length
        self.encoding = encoding

        input_file = os.path.join(data_dir, "input.txt")
        vocab_file = os.path.join(data_dir, "vocab.pkl")
        tensor_file = os.path.join(data_dir, "data.npy")

        if not (os.path.exists(vocab_file) and os.path.exists(tensor_file)):
            print("reading text file")  # 预处理
            self.preprocess(input_file, vocab_file, tensor_file)
        else:
            print("loading preprocessed files")
            self.load_preprocessed(vocab_file, tensor_file)
        self.create_batches()
        self.reset_batch_pointer()

    def preprocess(self, input_file, vocab_file, tensor_file):
        """pass

        """
        with codecs.open(input_file, "r", encoding=self.encoding) as f:
            data = f.read()
        counter = collections.Counter(data)

        # (word, freq) pair按降序排列，用于字符编码
        #
        # 蓝
        count_pairs = sorted(counter.items(), key=lambda x: -x[1])
        self.chars, _ = zip(*count_pairs)  # 解压
        self.vocab_size = len(self.chars)
        self.vocab = dict(zip(self.chars, range(len(self.chars))))
        with open(vocab_file, 'wb') as f:  # 二进制写入出现的字符
            cPickle.dump(self.chars, f)
        # 依据字符编码，字符转化为数字
        self.tensor = np.array(list(map(self.vocab.get, data)))
        np.save(tensor_file, self.tensor)

    def load_preprocessed(self, vocab_file, tensor_file):
        """pass

        """
        with open(vocab_file, 'rb') as f:
            self.chars = cPickle.load(f)
        self.vocab_size = len(self.chars)
        self.vocab = dict(zip(self.chars, range(len(self.chars))))
        self.tensor = np.load(tensor_file)
        self.num_batches = int(self.tensor.size / (self.batch_size *
                                                   self.seq_length))

    def create_batches(self):
        """pass

        """
        self.num_batches = int(self.tensor.size / (self.batch_size *
                                                   self.seq_length))  # batch数

        # When the data (tensor) is too small,
        # let's give them a better error message
        if self.num_batches == 0:
            assert False, "Not enough data. Make seq_length and batch_size small."

        self.tensor = self.tensor[  # 去掉一些零头
            :self.num_batches * self.batch_size * self.seq_length
        ]
        xdata = self.tensor
        ydata = np.copy(self.tensor)
        ydata[:-1] = xdata[1:]
        ydata[-1] = xdata[0]
        self.x_batches = np.split(xdata.reshape(self.batch_size, -1),
                                  self.num_batches, 1)
        self.y_batches = np.split(ydata.reshape(self.batch_size, -1),
                                  self.num_batches, 1)

    def next_batch(self):
        """pass

        """
        _x, _y = self.x_batches[self.pointer], self.y_batches[self.pointer]
        self.pointer += 1
        return _x, _y

    def reset_batch_pointer(self):
        """pass

        """
        self.pointer = 0


def test():
    """test

    """
    data_loader = TextLoader(  # pylint: disable=W0612
        data_dir='data/tinyshakespeare',
        batch_size=50,
        seq_length=50
    )

if __name__ == '__main__':
    test()
