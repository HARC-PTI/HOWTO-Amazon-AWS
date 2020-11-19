# Packer AWS examples

Here are a couple example Packer build templates for building AWS AMIs.

See [main AWS-AMI-Packer README file](../README.md) for instructions on setting up Packer and AWS CLI to run these example Packer build templates.

Each of the examples uses the amazon-ebs Packer builder. More info on that builder can be found here: [https://www.packer.io/docs/builders/amazon/ebs](https://www.packer.io/docs/builders/amazon/ebs). There are also additional AWS builders that can be used with Packer for creating other AWS resources besides AMIs.

## rhel-aws-packer-example-1.json

This Packer build template example uses a RHEL base AMI to build the temporary EC2 instance. After creating the instance, Packer copies over a directory containing Ansible scripts to the temporary instance and then runs a script ([run-ansible.sh](extras/example-1/run-ansible.sh)) within the temporary instane that (1) installs Ansible within the temporary instance and (2) runs the ansible-playbook command within the temporary instance, using the Ansible scripts that were copied to the system. After that is done, Packer then creates the AMI from that temporary instance.

In order to use the official RHEL AMIs as the base image, the base AMI owner is set to `309956199498`, Red Hat's AWS owner/account ID for AMIs. (Note: This AWS owner/account ID for Red Hat will work in any commercial AWS region. If using a AWS GovCloud region, you will need to use the AWS owner/account ID of `219670896067` to find the official RHEL AMIs in those regions.) (See [Red Hat article](https://access.redhat.com/solutions/15356).) The build template is set to always use the latest RHEL AMI available, using the RHEL version specified as an environment variable (see below). The filter name may need to be adjusted if using a RHEL major version other than RHEL 7.

Prior to using this example build template with Packer, you will need to set the following environment variables in your current shell:

- packer_aws_region
- packer_os_version
- packer_build_author

Example:

          export packer_aws_region="us-east-2"
          export packer_os_version="7.9"
          export packer_build_author="John Doe"
          packer build rhel-aws-packer-example-1.json


## rhel-aws-packer-example-2.json

This Packer build template examples uses a RHEL base AMI to build a temporary EC2 instance. After creating the instance, Packer copies over a file into a directory within the instance ([history_timestamp.sh](extras/example-2/history_timestamp.sh)) and then runs a separate bash script ([bootstrap.sh](extras/example-2/bootstrap.sh)) that makes various changes to the system. After that is done, Packer then creates the AMI from that temporary instance.

See the note in the first example regarding the use of the official RHEL AMIs as the base image.

Prior to using this example build template with Packer, you will need to set the following environment variables in your current shell:

- packer_aws_region
- packer_build_author

Example:

          export packer_aws_region="us-east-2"
          export packer_build_author="John Doe"
          packer build rhel-aws-packer-example-2.json


## rhel-aws-packer-example-3.json

This Packer build template examples uses a RHEL base AMI to build a temporary EC2 instance. After creating the instance, Packer uses a local installation of Ansible to run a local Ansible playbook remotely through the current SSH connection to the temporary instance already established by Packer. The Ansible playbook ([ansible.yml](extras/example-3/ansible.yml)) contains an "apache" role ([extras/example-3/roles/apache/](extras/example-3/roles/apache/)) that sets up a simple Apache httpd web server to serve a single static HTML file.

Prior to using this example build template with Packer, you will need to take a couple actions first:

First, you will need to make sure Ansible is installed locally on the system where you are running the Packer build command, since Packer will use this to run the Ansible playbook. There are various ways to install Ansible, but one of the easiest ways is to use the 'pip3' command to install the ansible Python3 package:

	pip3 install ansible

This assumes you have Python 3 and pip installed on your local system (directions for which are beyond the scope of this HOW-TO). Additional ways to install Ansible can be found here: [https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

Second, you will need to set the following environment variables in your current shell:

- packer_aws_ssh_user
- packer_aws_region
- packer_aws_subnet_id
- packer_aws_vpc_id

Example:

          export packer_aws_ssh_user="ec2-user"
          export packer_aws_region="us-east-2"
          export packer_aws_subnet_id="subnet-XXXXXXXXXXXXXXXXX"
          export packer_aws_vpc_id="vpc-XXXXXXXXXXXXXXXXX"
          packer build rhel-aws-packer-example-3.json

