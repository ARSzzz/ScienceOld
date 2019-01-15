"""
tmp file.
"""

import os

txt = b'hello world!'

with open('others/test', 'rb') as f:
    data = f.write(txt)


