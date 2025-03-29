---
title: chroot
date: 2025-03-21
private: true
---
# chroot example
prepare binary path:

    mkdir -p $HOME/jail/{bin,lib64}
    cd $HOME/jail
    cp -v /bin/{bash,ls} $HOME/jail/bin

prepare .so files

    > ldd /bin/bash
	linux-vdso.so.1 (0x00007fff13dfd000)
	libtinfo.so.5 => /lib/x86_64-linux-gnu/libtinfo.so.5 (0x00007f6d18435000)
	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f6d18231000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f6d17e40000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f6d18979000)


    # 获取bash依赖的动态链接库列表
    libs=$(ldd /bin/bash | grep -v 'linux-vdso.so.1' | awk '{print $3}' | grep -v '^$')

    # 添加ld-linux文件（通常在最后一行，格式不同）
    ld_linux=$(ldd /bin/bash | grep '/lib64/ld-linux' | awk '{print $1}')
    if [ -n "$ld_linux" ]; then
        libs="$libs $ld_linux"
    fi

    # 复制每个依赖库到目标目录
    echo "开始复制 bash 依赖的动态链接库..."
    for lib in $libs; do
        if [ -f "$lib" ]; then
            echo "复制: $lib"
            cp -L "$lib" ~/jail/lib64/
        else
            echo "警告: 无法找到库文件 $lib"
        fi
    done

最后

    sudo chroot ~/jail /bin/bash