# Author: Philipp Witte (pwitte3@gatech.edu)
# Copyright (c) 2019 Georgia Institute of Technology

FROM ubuntu:18.04

# Install packages
#RUN apt-get update
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y iproute2 cmake openssh-server openssh-client python3 python3-pip build-essential gfortran mpich
RUN apt-get install -y vim git-core

# Python packages
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade --user awscli boto3
RUN ln -s /root/.local/bin/aws /usr/local/bin/aws

# Set up SSH
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ENV SSHDIR /root/.ssh
RUN mkdir -p ${SSHDIR}
RUN touch ${SSHDIR}/sshd_config
RUN ssh-keygen -t rsa -f ${SSHDIR}/ssh_host_rsa_key -N ''
RUN cp ${SSHDIR}/ssh_host_rsa_key.pub ${SSHDIR}/authorized_keys
RUN cp ${SSHDIR}/ssh_host_rsa_key ${SSHDIR}/id_rsa
RUN echo " IdentityFile ${SSHDIR}/id_rsa" >> /etc/ssh/ssh_config
RUN echo "Host *" >> /etc/ssh/ssh_config && echo " StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN chmod -R 600 ${SSHDIR}/* && \
    chown -R ${USER}:${USER} ${SSHDIR}/
RUN eval `ssh-agent -s` && ssh-add ${SSHDIR}/id_rsa

# Add mpi set-up script and thread pinning script
ADD ./mpi_run.sh /app/mpi_run.sh
RUN chmod 755 /app/mpi_run.sh

# Run mpi script upon docker launch
EXPOSE 22
WORKDIR /app
CMD ["./mpi_run.sh"]
