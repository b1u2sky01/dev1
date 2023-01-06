#!/bin/bash

# 볼륨체크
# lsblk
# sudo file -s /dev/xvdf 디바이스 정보확인
# sudo lsblk -f 디바이스 파일 연결 정보 확인

SVCFNAME="/dev/xvds"
LOGSFNAME="/dev/xvdl"

if [ "`lsblk -f | grep "nvme" | wc -l`" -gt 0 ]; then
 # t3 이상
 LOGSFNAME="/dev/nvme1n1"
 SVCFNAME="/dev/nvme2n1"
fi

# file 시스템 생성 및 마운트
 sudo mkfs -t xfs -f $SVCFNAME
 sudo mkdir /svc
 sudo mount $SVCFNAME /svc

# logs mount 파일시스템 생성 및 마운트
sudo mkfs -t xfs -f $LOGSFNAME
sudo mkdir /logs
sudo mount $LOGSFNAME /logs


sudo cp /etc/fstab /etc/fstab.orig

###################################
# 0을 지정하여 파일 시스템이 덤프되지 않도록 하고 2를 지정하여 루트 디바이스가 아님을 표시
###################################
# 재부팅시 자동 mount 설정
# 1. 파일 복사 백업

# SVC UUID 추가
SVCUUID=`sudo blkid | grep $SVCFNAME | cut -d '"' -f2`
if [ `echo $SVCUUID | wc -l` -gt 0 ] ; then
# svc mount 파일시스템 생성 및 마운트
echo "UUID=$SVCUUID  /svc  xfs  defaults,nofail  0  2" | sudo tee -a /etc/fstab
fi

# LOGS UUID 추가
LOGUUID=`sudo blkid | grep $LOGSFNAME | cut -d '"' -f2`
if [ `echo $LOGUUID | wc -l` -gt 0 ] ; then
echo "UUID=$LOGUUID  /logs  xfs  defaults,nofail  0  2" | sudo tee -a /etc/fstab
fi

sudo mount -a

# End of mount

# update yum and install nginx
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y

# install nvm
su - ec2-user -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash'
su - ec2-user -c '. ~/.nvm/nvm.sh'
su - ec2-user -c 'chmod 700 .nvm/nvm.sh'
su - ec2-user -c 'nvm install node'
su - ec2-user -c 'nvm install 16'
su - ec2-user -c 'nvm use 16'
su - ec2-user -c 'echo `node -v` >> nodeinstall.log'
