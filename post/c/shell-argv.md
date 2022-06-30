---
title: shell argv
date: 2019-05-17
---
# shell argv

    ${1:"default"}

# parse argv

    # bash a.sh -f -o a.txt 
    parse_argv(){
        while test $# -gt 0; do
            case "$1" in
                (-f) force=1;;
                (-o) outfile=$2;
                    shift;;
                (*) help=1;;
            esac
            shift
        done
    }
    parse_argv "$@"
    echo -f:$force
    echo -o:$outfile
    echo -h:$help

# optional

    while getopts "a:bc" arg #选项后面的冒号表示该选项需要参数
    do
            case $arg in
                a)
                    echo "a's arg:$OPTARG" #参数存在$OPTARG中
                    ;;
                d)
                    echo "d's arg:$OPTARG" #参数存在$OPTARG中
                    ;;

                b)
                    echo "b"
                    ;;
                c)
                    echo "c"
                    ;;
                ?)  
                echo "unkonw argument"
            exit 1
            ;;
            esac
    done

test:

    # -b -c 是开关
    sh test.sh -a name -b -c
    sh test.sh -a name -bc
    sh test.sh -bca name
