"""
Register
"""


class Register:
    def __init__(self):
        self.string = ''
    
    def add(self, string):
        self.string = self.string + '\n' + string
    
    def save(self):
        with open('Register.txt', 'a') as fp:
            fp.write(self.string)
        
        self.string = ''

    def sum(self):
        with open('Register.txt', 'r') as fp:
            current = fp.read()

        return len(current)


if __name__ == "__main__":
    pass
