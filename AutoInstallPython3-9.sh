#!/bin/bash
filePath="/usr/local/python3"
num=0
#安装目录
if [ ! -e  $filePath ]; then
    mkdir -p /usr/local/python3
fi
if [ ! -e $filePath/make ]; then 
    mkdir -p $filePath/make
fi
if [ ! -e $filePath/Configure ]; then 
    mkdir -p $filePath/Configure
    touch $filePath/Configure/err-configure.log
fi
# yum源更新并清理
installAndClean(){
    yum -y update && yum clean all 
    return $?
}

# 安装wget命令并且安装python依赖
installPackage(){
    yum -y install wget zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel gcc make
    return $?
}

# 下载python包
downloadPython(){
    cd $filePath
    wget -q https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tgz 
    return $?
}

# 安装Python  
installPython(){
    cd $filePath
    echo "正在解压Python-3.9.9.tgz中..."
    tar -zxf Python-3.9.9.tgz -C $filePath
    cd $filePath/Python-3.9.9
    # 添加python配置
    echo "正在添加python配置..."
    if [ ! -e  $filePath/Configure/err-configure.log ]; then
        touch $filePath/Configure/err-configure.log
        
    elif [ ! -e  $filePath/Configure/run-configure.log ];then
        touch $filePath/Configure/run-configure.log
    fi
    if $(./configure --prefix=$filePath 1>$filePath/Configure/run-configure.log 2>$filePath/Configure/err-configure.log); then
        # 编译python安装目录文件
        echo "正在make编译Python安装目录文件..."
        if [ ! -e  $filePath/make/run-make.log ]; then
            touch $filePath/make/run-make.log 
            
        elif [ ! -e  $filePath/make/err-make.log ];then
            touch $filePath/make/err-make.log
        fi
        if $(make 1>$filePath/make/run-make.log 2>$filePath/make/err-make.log); then
            echo "正在make install编译安装Python目录文件..."
            if [ ! -e  $filePath/make/run-make-install.log ]; then
                touch $filePath/make/run-make-install.log 
                
            elif [ ! -e  $filePath/make/err-make-install.log ];then
                touch $filePath/make/err-make-install.log
            fi
            if $(make install 1>$filePath/make/run-make-install.log 2>$filePath/make/err-make-install.log); then
                cp -r $filePath /usr/bin/
                mv /usr/bin/python3 /usr/bin/python399

                # 创建python3软连接
                echo "创建python3软连接..."
                ln -s $filePath/bin/python3 /usr/bin/python3

                # 创建pip3软连接
                echo "创建pip3软连接..."
                ln -s $filePath/bin/pip3.9 /usr/bin/pip3

                # 写入/etc/profile文件
                echo "写入/etc/profile文件..."
                echo "# Python-3.9.9" >>/etc/profile
                echo "PATH=\$PATH:\$HOME/bin:/usr/bin/python3/bin" >>/etc/profile
                echo "export PATH" >>/etc/profile
                source /etc/profile

                echo "安装成功!! 版本为：`python3 -V`"
                echo "pip3 版本为：`pip3 -V`"
            else
                echo "make install编译安装失败!!!去$filePath/make目录下查看run-make-install.log和err-make-install.log"
            fi
                    
        else
            echo "make编译失败!!!去$filePath/make目录下查看run-make.log和err-make.log"
        fi
    else
        echo "添加python配置失败!!!去$filePath/Configure目录下查看run-configure.log和err-configure.log"
    fi
}

echo "yum源更新清理中..."
if installAndClean; then 
    echo "安装wget和python依赖文件..."
    if installPackage; then
        if [ ! -e $filePath/Python-3.9.9.tgz ]; then
            echo "正在下载Python-3.9.9.tgz中..."
            if downloadPython; then
                installPython
            else
                echo "下载失败!!!"
            fi
        else
            if [ ! -e $filePath/Python-3.9.9 ];then
                installPython
            else
                rm -rf Python-3.9.9
                installPython
            fi
        fi
        
    else
        echo "安装wget命令并且安装python依赖失败!!!"   
    fi

else
    echo "yum update和clean all失败!!!"
fi
