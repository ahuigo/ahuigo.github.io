# python 加密实例
[加密算法简介](/p/algorithm/algorithm-crypt)

# AES

## aes-256-cbc 算法实例
### node example

    engine = 'aes-256-cbc'; //aes-256-ecb, aes192, ...
    crypto = require('crypto')
    log= console.log
    ivx = true
    class Aes{
        static encryptAes256Cbc(text, _key){
            var cipher;
            let m = crypto.createHash('sha256');
            m.update(_key);
            let key = m.digest();
            let iv = Buffer.from([...Array(16).keys()])
            cipher = crypto.createCipheriv(engine, key, iv);
            //cipher = crypto.createCipher(engine, key); // deprecated: iv 复用风险
            cipher.setAutoPadding(true)
            let ciph = cipher.update(text, 'utf8', 'base64'); //base64, hex ...
            ciph += cipher.final('base64');
            return ciph;
        }

        static decryptAes256Cbc(text, _key){
            var decipher;
            let m = crypto.createHash('sha256');
            m.update(_key);
            let key = m.digest();
            let iv = Buffer.from([...Array(16).keys()])
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

### python3 example

    import base64
    from Crypto.Cipher import AES
    from Crypto.Hash import SHA256
    from Crypto import Random

    def encrypt(key, source):
        source = source.encode()
        key = SHA256.new(key.encode()).digest()  
        IV = bytes(range(16))
        encryptor = AES.new(key, AES.MODE_CBC, IV)
        padding = AES.block_size - len(source) % AES.block_size  
        source += bytes([padding]) * padding 
        data = encryptor.encrypt(source)  
        return base64.b64encode(data).decode("utf8")

    def decrypt(key, source):
        source = base64.b64decode(source.encode("utf8"))
        key = SHA256.new(key.encode()).digest()  
        IV = bytes(range(16))
        decryptor = AES.new(key, AES.MODE_CBC, IV)
        data = decryptor.decrypt(source)  
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

### 随机IV
有时我们想随机产生一个IV,  此时IV 应该像pading 一样`保存`到加密结果的头或者尾部

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
        enc = encryptor.encrypt(source) 
        data = IV + enc # store the IV at the beginning and encrypt    
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

Warn: 
1. 随机IV 会导致 aes-cbc 加密结果(加IV前)是随机的
2. ECB 会忽略IV 

### 固定iv的风险
很多示例是用的内部默认的iv，固定的iv 会有风险:
1. https://stackoverflow.com/questions/3008139/why-is-using-a-non-random-iv-with-cbc-mode-a-vulnerability
2. https://crypto.stackexchange.com/questions/5094/is-aes-in-cbc-mode-secure-if-a-known-and-or-fixed-iv-is-used

## aes-ecb
ecb 不需要iv

    from Crypto.Cipher import AES
    def pad(text):
        text = text.encode()
        return text + b' ' * (16 - len(text) % 16)

    key = 'password'
    aes = AES.new(pad(key), AES.MODE_ECB)
    text = '数据'
    enc = aes.encrypt(pad(text))
    print(enc)

    de = aes.decrypt(enc).decode()
    print(de[:len(text)]) # remove padding
