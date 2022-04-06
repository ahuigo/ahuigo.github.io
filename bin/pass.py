#!/usr/bin/env python3
import sys,os
import base64
from Crypto.Cipher import AES
from Crypto.Hash import SHA256
from Crypto import Random

def encrypt(key, source):
    key = SHA256.new(key.encode()).digest()  
    IV = bytes(range(16))
    encryptor = AES.new(key, AES.MODE_CBC, IV)
    padding = AES.block_size - len(source) % AES.block_size  
    source += bytes([padding]) * padding 
    data = encryptor.encrypt(source)  
    return base64.b64encode(data)

def decrypt(key, source):
    source = base64.b64decode(source)
    key = SHA256.new(key.encode()).digest()  
    IV = bytes(range(16))
    decryptor = AES.new(key, AES.MODE_CBC, IV)
    data = decryptor.decrypt(source)  
    padding = data[-1]  # pick the padding value from the end;
    if data[-padding:] != bytes([padding]) * padding:
        raise ValueError("Invalid padding...")
    return data[:-padding]  # remove the padding

def decode(path):
    if 	not os.path.exists(path): quit("bad path:"+path)
    s=open(path, 'rb').read()
    key=input("pls input key:")
    s=decrypt(key, s)
    r=b''
    for i in s:
        r+=decode_c(i)
    return r

def encode(path, to_path):
    if 	not os.path.exists(path): quit("bad path:"+path)
    s=open(path,'rb').read()
    r=b''
    for i in s:
        ei=encode_c(i)
        r = r+ei
    key=input("pls input key:")
    r=encrypt(key, r)
    
    if 	os.path.exists(to_path): 
        print(to_path, 'exists!')
        quit()

    with open(to_path, 'wb') as f:
        print("write to:", to_path)
        f.write(r)
    
def encode_c(i):
    i=(i+10)%256
    c = i.to_bytes(1, byteorder='big')
    return c


def decode_c(i):
    i=(i-10)%256
    c=i.to_bytes(1, byteorder='big')
    return c

"""""""""""
p pass.py -e path to_path
p pass.py -d to_path
"""""""""""
if __name__ == '__main__':
    if '-e' in sys.argv:
        if len(sys.argv)<4:
            quit('bad argv!')
        encode(sys.argv[2], sys.argv[3])
    if '-d' in sys.argv:
        print(decode(sys.argv[2]))
