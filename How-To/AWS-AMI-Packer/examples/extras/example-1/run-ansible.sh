#!/bin/bash

set -e

usage="Script to install and run Ansible

$(basename "$0") [-h]

where:
  -h   Show this help text
  -f   Role/playbook name (default: base-os) [base-os]
  -r   Run method (default: local) [local|packer]
"

if [ $# -le 1 ]; then
    echo "$usage"
    exit 1
fi

# default variable values
ANSIBLE_DIR=/tmp/ansible
PLAYBOOK_FILE=base-os.yml
TMP_DIR=/tmp
RUN_METHOD=local

# parsing options
while getopts ':h:f:i:c:t:s:r:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    f) PLAYBOOK_FILE=$OPTARG.yml
       ;;
    i) TOP_DIR=$OPTARG
       ;;
    r) RUN_METHOD=$OPTARG
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

### If running through Packer
if [ "$RUN_METHOD" == "packer" ]; then
    cd $ANSIBLE_DIR
fi

if [ ! -f $PLAYBOOK_FILE ]; then
    echo -e "Unsupported playbook. File $PLAYBOOK_FILE does not exist"
    exit 1
fi

#### If running locally to test
if [ "$RUN_METHOD" == "local" ]; then
    mkdir -p $ANSIBLE_DIR/
    cd $ANSIBLE_DIR/
    tar xzf $TMP_DIR/ansible.tar.gz
fi

# install ansible
if ! (which ansible-playbook) >/dev/null 2>&1; then
    # prereqs
    yum install -y python3 python3-pip

    # install ansible
    pip3 install ansible
fi

export PATH=$PATH:/usr/local/sbin:/usr/local/bin

# running ansible
ansible-playbook --verbose --connection=local -i inventory/hosts.yml ${PLAYBOOK_FILE}

if [ "$RUN_METHOD" == "packer" ]; then
  rm -rf $ANSIBLE_DIR
fi

