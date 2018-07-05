# python 下的加密

## AES
本例子为aes-256-cbc 算法示例

    import base64
    from Crypto.Cipher import AES
    from Crypto.Hash import SHA256
    from Crypto import Random

    def encrypt(key, source, encode=True):
        key = SHA256.new(key).digest()  
        IV = Random.new().read(AES.block_size)  
        encryptor = AES.new(key, AES.MODE_CBC, IV)
        padding = AES.block_size - len(source) % AES.block_size  
        source += bytes([padding]) * padding  
        data = IV + encryptor.encrypt(source)  # store the IV at the beginning and encrypt
        return base64.b64encode(data).decode("latin-1") if encode else data

    def decrypt(key, source, decode=True):
        if decode:
            source = base64.b64decode(source.encode("utf8"))
        key = SHA256.new(key).digest()  # use SHA-256 over our key to get a proper-sized AES key
        IV = source[:AES.block_size]  # extract the IV from the beginning
        decryptor = AES.new(key, AES.MODE_CBC, IV)
        data = decryptor.decrypt(source[AES.block_size:])  # decrypt
        padding = data[-1]  # pick the padding value from the end; Python 2.x: ord(data[-1])
        if data[-padding:] != bytes([padding]) * padding:  # Python 2.x: chr(padding) * padding
            raise ValueError("Invalid padding...")
        return data[:-padding]  # remove the padding


    my_password = b"secret_AES_key_string_to_encrypt/decrypt_with"
    my_data = b"input_string_to_encrypt/decrypt"

    encrypted = encrypt(my_password, my_data)
    decrypted = decrypt(my_password, encrypted)

    print("key:  {}".format(my_password))
    print("data: {}".format(my_data))
    print("enc:  {}".format(encrypted))
    print("data match: {}".format(my_data == decrypted))