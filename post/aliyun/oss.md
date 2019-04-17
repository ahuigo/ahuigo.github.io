---
title: Aliyun oss
date: 2019-04-17
---
# oss
OSS开源工具ossutil-增量上传: 
https://yq.aliyun.com/articles/601447

OSS开源工具ossutil-并发
https://yq.aliyun.com/articles/620574 ossutil 使用了并发

python3 版的多进程并发：

```python
import oss2
import os
from oss2.api import Bucket
from pathlib import Path
from multiprocessing import Pool
import functools

"""
Example:
bucket = Oss2Bucket(oss['AccessKeyId'], oss['AccessKeySecret'], oss['EndPoint'], bucket_name)
bucket.download_from_cloud(remote_dir, local_dir)
"""
class Oss2Bucket(Bucket):
    def __init__(self, AccessKeyId, AccessKeySecret, EndPoint, bucket_name):
        auth = oss2.Auth(AccessKeyId, AccessKeySecret)
        super().__init__(auth, EndPoint, bucket_name)

    """
    oss 文件夹上传
    """
    def upload_to_cloud(bucket, local_dir, remote_dir, pool_num=30, chunksize=100):
        local_dir = Path(local_dir)
        remote_dir = Path(remote_dir)
        try:
            filelist = bucket.get_local_filelist(local_dir)
            pool = Pool(pool_num)
            pool.map(functools.partial(bucket.upload_file, local_dir, remote_dir), filelist, chunksize=chunksize)
        except Exception as err:
            raise Exception("Upload {} to oss failed remote_dir: {}, local_dir: {}".format(err, remote_dir, local_dir))


    """
    oss 文件夹下载(默认30进程)
    """
    def download_from_cloud(bucket, remote_dir, local_dir, pool_num=30, chunksize=100):
        try:
            filelist = bucket.get_cloud_filelist(remote_dir)
            pool = Pool(pool_num)
            pool.map(functools.partial(bucket.download_file, remote_dir, local_dir), filelist, chunksize=chunksize)
            
        except Exception as err:
            raise Exception("Download {} to oss failed {}".format(os.path.basename(remote_dir), err))

    """
    get local filelist
    """
    def get_local_filelist(self, local_dir):
        for local_file in local_dir.glob('**/*.*'):
            yield local_file

    """
    upload_file
    """
    def upload_file(bucket, local_dir, remote_dir, local_file):
        remote_file = remote_dir/local_file.relative_to(local_dir)
        bucket.put_object_from_file(str(remote_file), str(local_file))

    """
    get_cloud_filelist
    """
    def get_cloud_filelist(bucket, remote_dir):
        remote_dir = remote_dir.strip('/')+'/'
        read_dir = True
        next_marker = False
        while read_dir:
            bl = bucket.list_objects(remote_dir, marker=next_marker, max_keys=1000)
            next_marker = bl.next_marker
            for remote_file in bl.object_list:
                if not remote_file.key.endswith('/'):
                    yield remote_file.key
            read_dir = next_marker

    """
    download file
    """
    def download_file(bucket, remote_dir, local_dir, remote_file):
            local_file = Path(local_dir)/Path(remote_file).relative_to(remote_dir)
            if not local_file.parent.exists():
                try:
                    os.makedirs(str(local_file.parent))
                except:
                    print("Create dir: %s failed" % str(local_file.parent))
            bucket.get_object_to_file(str(remote_file), str(local_file))

```