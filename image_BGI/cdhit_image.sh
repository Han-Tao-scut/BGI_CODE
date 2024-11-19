#!/bin/bash
#环境，华大云平台
#base image:miniforece_v1.0

#创建目录，赋权限
mkdir -p /home/stereonote
chown -R 10000:100 /home/stereonote

#授予超级权限，optional
mkdir /etc/yum.repos.d/bak
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak
wget -O /etc/yum.repos.d/Centos-7.repo http://mirrors1.sz.cngb.org/repository/os/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors1.sz.cngb.org/repository/os/repo/epel7.repo
yum clean all
yum makecache
yum install -y sudo
chmod 444 /etc/sudoers
echo -e "stereonote\tALL=(ALL)\tNOPASSWD: ALL" >> /etc/sudoers

#安装软件
conda install -c bioconda cd-hit -y
conda install -c conda-forge parallel -y

#清理缓存
conda clean --all -y

