#!/bin/bash

SVCFNAME="/dev/xvds"
LOGSFNAME="/dev/xvdl"

if [ "`lsblk -f | grep "nvme" | wc -l`" -gt 0 ]; then
 LOGSFNAME="/dev/nvme1n1"
 SVCFNAME="/dev/nvme2n1"
fi

 sudo mkfs -t xfs -f $SVCFNAME
 sudo mkdir /svc
 sudo mount $SVCFNAME /svc

sudo mkfs -t xfs -f $LOGSFNAME
sudo mkdir /logs
sudo mount $LOGSFNAME /logs


sudo cp /etc/fstab /etc/fstab.orig

SVCUUID=`sudo blkid | grep $SVCFNAME | cut -d '"' -f2`
if [ `echo $SVCUUID | wc -l` -gt 0 ] ; then
echo "UUID=$SVCUUID  /svc  xfs  defaults,nofail  0  2" | sudo tee -a /etc/fstab
fi

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
