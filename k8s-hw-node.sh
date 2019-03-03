#!/bin/bash

set -e;

systemctl stop firewalld && systemctl disable firewalld
setenforce 0
# vi /etc/selinux/config 
# # SELINUX=disabled

cat >> /etc/sysctl.conf<< EOF
net.ipv4.ip_forward= 1
net.bridge.bridge-nf-call-ip6tables= 1
net.bridge.bridge-nf-call-iptables= 1
EOF

sysctl -p

systemctl daemon-reload
systemctl restart docker

yum install -y src/*

cp cfg/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl enable kubelet && systemctl start kubelet

dd  if=/dev/zero of=/swapfile bs=100M count=10;
mkswap  /swapfile;
swapon /swapfile;
cat >> /etc/rc.local << EOF
swapon /swapfile
EOF
