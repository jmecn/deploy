#!/bin/bash

#--------------------------------------------
# 在服务器上为所需部署的应用创建目录
# author: 闫茂源
# date: 2020/05/11
#--------------------------------------------
BASE=/apps/srv/instance
SUB=backend
USER=

# 打印用法
function usage()
{
    echo 'Usage:'
    echo "    `basename $0` app_name [options] [app_name2] [app_name3]..."
    echo 'Options:'
    echo '    -b base_path          default: /apps/srv/instance'
    echo '    -s sub_dir            default: backend'
    echo '    -u user:group         default: NONE'
    echo 'Example:'
    echo "    sudo sh `basename $0` -b /apps/srv/instance -s backend -u admin:admin app1 app2 app3"
    echo -e '    \033[32mCREATED\033[0m: /apps/srv/instance/app1/backend'
    echo -e '    \033[33mEXIST\033[0m:   /apps/srv/instance/app2/backend'
    echo -e '    \033[31mFAILED\033[0m:  /apps/srv/instance/app3/backend'
    exit 1;
}

# 创建应用目录，并根据需要授权给用户组
function create()
{
    # 创建 /apps 目录
    if [[ ! -e $BASE ]]; then
        mkdir -p BASE
    fi

    # 去掉子目录前的 /
    if [[ ! -z $SUB ]]; then
        if [[ '/' == ${SUB:0:1} ]]; then
            SUB=${SUB:1}
        fi
    fi

    # 应用名
    APPS=$*

    # 遍历应用，目录不存在则创建
    for APP in ${APPS[*]}; do

        # 构造目录        
        if [[ -z $SUB ]]; then
            APP_DIR=$BASE/$APP
        else
            APP_DIR=$BASE/$APP/${SUB}
        fi

        # 判断目录是否存在
        if [[ -e ${APP_DIR} ]];
        then
            echo -e "\033[33mEXIST\033[0m:   $APP_DIR"
        else
            # 不存在则创建
            mkdir -p $APP_DIR

            # 为目录授权
            if [[ ! -z $USER ]]; then
                chown -R $USER $APP_DIR
            fi

            # 判断创建是否成功
            if [[ -e ${APP_DIR} ]];
            then
                echo -e "\033[32mCREATED\033[0m: $APP_DIR"
            else
                echo -e "\033[31mFAILED\033[0m:  $APP_DIR"
            fi
        fi
    done

    exit 1;
}

# 解析输入参数
while getopts 'b:s:u:h' OPT; do
    case $OPT in
        b)
            BASE="$OPTARG";;
        s)
            SUB="$OPTARG";;
        u)
            USER="$OPTARG";;
        h)
            usage;;
        ?)
            usage;;
    esac
done

shift $(($OPTIND - 1))

# 如果传入参数不为空则创建目录，参数为空则打印出用法。
if [[ $# == 0 ]];
then
    usage
else
    create $*
fi


