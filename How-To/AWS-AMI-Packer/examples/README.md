# Packer AWS examples

Here are some example Packer build templates to build AWS AMIs.

See [main Packer README file](../README.md) for instructions on setting up Packer and AWS CLI to run these example Packer build templates.

Each of the examples uses the amazon-ebs Packer builder. More info on that builder can be found here: [https://www.packer.io/docs/builders/amazon/ebs](https://www.packer.io/docs/builders/amazon/ebs). There are also additional AWS builders that can be used with Packer for creating other AWS resources besides AMIs.

## rhel-aws-packer-example-1.json

This Packer build template example uses a RHEL base AMI to build the temporary EC2 instance. After creating the instance, Packer copies over a directory containing Ansible scripts to the temporary instance and runs a script that (1) installs Ansible within the temporary instance and (2) runs the ansible-playbook command within the temporary instance, using the Ansible files that were copied to the system. After that is done, Packer then creates the AMI from that temporary instance.

In order to use the official RHEL AMIs as the base image, the base AMI owner is set to `309956199498`, Red Hat's AWS owner/account ID for AMIs. (Note: This AWS owner/account ID for Red Hat will work in any commercial AWS region. If using a AWS GovCloud region, you will need to use the AWS owner/account ID of `219670896067` to find the official RHEL AMIs in those regions.) (See [Red Hat article](https://access.redhat.com/solutions/15356).) The build template is set to always use the latest RHEL AMI available, using the RHEL version specified as an environment variable (see below). The filter name may need to be adjusted if using a RHEL major version other than RHEL 7.

Prior to using this example build template with Packer, you will need to set the following environment variables in your current shell:

- packer_aws_region
- packer_os_version
- packer_build_author

Example:

          export packer_aws_region="us-east-1"
          export packer_os_version="7.8"
          export packer_build_author="John Doe"
          packer build rhel-aws-packer-example-1.json


## rhel-aws-packer-example-2.json

TO-DO: Explain what this example does.

Prior to using this example build template with Packer, you will need to set the following environment variables in your current shell:

- packer_build_author

Example:

          export packer_build_author="John Doe"
          packer build rhel-aws-packer-example-2.json


## rhel-aws-packer-example-3.json

TO-DO: Explain what this example does.

Prior to using this example build template with Packer, you will need to set the following environment variables in your current shell:

- AWS_SSH_USERNAME
- AWS_SUBNET_ID
- AWS_VPC_ID

Example:

          export AWS_SSH_USERNAME="ec2-user"
          export AWS_SUBNET_ID="subnet-XXXXXXXXXXXXXXXXX"
          export AWS_VPC_ID="vpc-XXXXXXXXXXXXXXXXX"
          packer build rhel-aws-packer-example-3.json

