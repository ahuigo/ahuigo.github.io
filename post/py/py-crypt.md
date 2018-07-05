# python 的加密

## AES

### aes-256-cbc 算法（随机iv）

    import base64
    from Crypto.Cipher import AES
    from Crypto.Hash import SHA256
    from Crypto import Random

    def encrypt(key, source):
        source = source.encode()
        key = SHA256.new(key.encode()).digest()  
        IV = Random.new().read(AES.block_size)  
        encryptor = AES.new(key, AES.MODE_CBC, IV)
        padding = AES.block_size - len(source) % AES.block_size  
        source += bytes([padding]) * padding
        data = IV + encryptor.encrypt(source)  # store the IV at the beginning and encrypt
        return base64.b64encode(data).decode("utf8")

    def decrypt(key, source):
        source = base64.b64decode(source.encode("utf8"))
        key = SHA256.new(key.encode()).digest()  
        IV = source[:AES.block_size]  # extract the IV from the beginning
        decryptor = AES.new(key, AES.MODE_CBC, IV)
        data = decryptor.decrypt(source[AES.block_size:])  # decrypt
        padding = data[-1]  # pick the padding value from the end; 
        if data[-padding:] != bytes([padding]) * padding:  
            raise ValueError("Invalid padding...")
        return data[:-padding].decode()  # remove the padding


    my_password = "password"
    my_data = "数据"

    encrypted = encrypt(my_password, my_data)    
    decrypted = decrypt(my_password, encrypted)    

    print("key:  {}".format(my_password))    
    print("data: {}".format(my_data))    
    print("enc:  {}".format(encrypted))    
    print("dec:  {}".format(decrypted))    
    print("data match: {}".format(my_data == decrypted))

### 非随机iv
node:

    engine = 'aes-256-cbc'
    inputEncoding = 'utf8'
    outputEncoding = 'base64'
    crypto = require('crypto')
    log= console.log
    ivx = true
    class Aes{
        static encryptAes256Cbc(text, _key){
            let m = crypto.createHash('sha256');
            m.update(_key);
            let key = m.digest();
            //console.log(_key,key)
            var cipher;
            let iv = Buffer.alloc(16,'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f');
            log('iv',iv)
            cipher = crypto.createCipheriv(engine, key, iv);
            //cipher = crypto.createCipher(engine, key);
            cipher.setAutoPadding(true)
            let ciph = cipher.update(text, 'utf8', 'base64');
            ciph += cipher.final('base64');
            return ciph;
        }

        static decryptAes256Cbc(text, _key){
            var decipher;
            let m = crypto.createHash('sha256');
            m.update(_key);
            let key = m.digest();
            let iv = Buffer.alloc(16,'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f');
            decipher = crypto.createDecipheriv(engine, key, iv);
            // decipher.setAutoPadding(false)
            let txt = decipher.update(text,'base64', 'utf8');
            txt  = txt + decipher.final('utf8');
            return txt;
        } 
    }

    text = '数据'
    pass = 'password'
    enc = Aes.encryptAes256Cbc(text, pass)
    console.log(enc)
    dec = Aes.decryptAes256Cbc(enc, pass)
    console.log(enc, dec)

python3:

    import base64
    from Crypto.Cipher import AES
    from Crypto.Hash import SHA256
    from Crypto import Random
    import binascii

    def encrypt(key, source):
        source = source.encode()
        key = SHA256.new(key.encode()).digest()  
        IV = '\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f'.encode()
        encryptor = AES.new(key, AES.MODE_CBC, IV)
        padding = AES.block_size - len(source) % AES.block_size  
        source += bytes([padding]) * padding 
        data = encryptor.encrypt(source)  
        return base64.b64encode(data).decode("utf8")

    def decrypt(key, source):
        source = base64.b64decode(source.encode("utf8"))
        key = SHA256.new(key.encode()).digest()  
        IV = '\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f'.encode()
        decryptor = AES.new(key, AES.MODE_CBC, IV)
        data = decryptor.decrypt(source)  
        padding = data[-1]  # pick the padding value from the end; Python 2.x: ord(data[-1])
        if data[-padding:] != bytes([padding]) * padding:  # Python 2.x: chr(padding) * padding
            raise ValueError("Invalid padding...")
        return data[:-padding].decode()  # remove the padding


    my_password = "password"
    my_data = "数据"

    encrypted = encrypt(my_password, my_data)    
    decrypted = decrypt(my_password, encrypted)    

    '1546d89ec91632cdd2b6fd7d35f5c72b2d56903b1db5bacf763260c4d077'

    print("key:  {}".format(my_password))    
    print("data: {}".format(my_data))    
    print("enc:  {}".format(encrypted))    
    print("dec:  {}".format(decrypted))    
    print("data match: {}".format(my_data == decrypted))