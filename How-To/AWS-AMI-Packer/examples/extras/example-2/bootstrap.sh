#/bin/bash

echo -e "\n** Disabling SELINUX"
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

echo -e "\n** Setting correct time zone"
timedatectl set-timezone America/Indiana/Indianapolis

echo -e "\n** Converting groups"
yum groups mark convert
echo -e "\n** Installing 'X Window System' yum group"
yum groups install -y 'X Window System'
echo -e "\n** Installing 'Development Tools' yum group"
yum groups install -y 'Development Tools'
echo -e "\n** Installing common/useful packages"
yum install -y deltarpm acpid bind-utils bash-completion screen xinetd man psmisc mlocate net-tools yum-utils lsof vim tmux

echo -e "\n** Disabling and removing firewalld (handled by AWS security groups)"
systemctl disable firewalld.service
yum remove firewalld -y

echo -e "\n** Enabling optional and extras repos"
yum-config-manager --enable rhel-7-server-rhui-optional-rpms rhel-7-server-rhui-extras-rpms --save

echo -e "\n** Installing python3 and python3-pip"
yum install -y python3 python3-pip

echo -e "\n** Installing awscli python package"
pip3 install -U awscli

echo -e "\n** Moving history_timestamp.sh file into place"
mv /tmp/history_timestamp.sh /etc/profile.d/.

echo -e "\n** Fully updating system"
yum update -y

echo -e "\n** DONE with bootstrap **\n"
