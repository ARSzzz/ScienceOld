class Sync:
    def __init__(self):
        self.txt = ''

    def add(self, string):
        self.txt = self.txt + string + '\n'
    
    def input(self):
        string = input()
        self.add(string)

    def save(self):
        with open('sync.txt', 'a', encoding='gbk') as fp:
            fp.write(self.txt)
            self.txt = ''
