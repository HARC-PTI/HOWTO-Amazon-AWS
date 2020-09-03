# Using Packer with AWS

Packer is a free, open-source, and vendor-agnostic tool that allows you to automate the creation of images for various platforms, including AWS EC2, Google Cloud, Azure, Docker, DigitalOcean, VirtualBox, VMware, and many more.

More info on Packer can be found at [https://www.packer.io](https://www.packer.io).
The source code for Packer can be found at [https://github.com/hashicorp/packer](https://github.com/hashicorp/packer).

This document will be specific for how to use Packer with AWS EC2 to create Amazon Machine Images (AMIs).

To do this, Packer will launch an EC2 instance on your behalf, create a temporary security group and SSH keypair to SSH into the instance, run the actions and/or provisioning tools you indicate (Ansible, Chef, Puppet, bash scripts, etc.) inside the instance, shut down the instance, create AMI from the instance in your AWS account, and then delete the EC2 instance and temporary security group and SSH keypair.

You can run Packer from your local desktop/laptop system, a remote system, or from a cloud instance, such as an AWS EC2 instance.

Several Packer build template examples can be found within the examples directory.

### You will need the following to run Packer with AWS:

* Packer installed    
	* See [https://learn.hashicorp.com/tutorials/packer/getting-started-install](https://learn.hashicorp.com/tutorials/packer/getting-started-install)
* AWS CLI installed
	* Note: If using Amazon Linux EC2 instance in AWS, the AWS CLI is already pre-installed for you.
	* See [https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

If running Packer from an AWS EC2 instance, you will need:
* AWS IAM role to attach to EC2 instance as IAM Instance Profile. The IAM role will need policies attached to allow Packer to make AWS EC2 CLI calls on your behalf. This can be one of:
	 * EC2FullAccess AWS policy
	 * Custom policy with a minimum of the permissions listed here: [https://www.packer.io/docs/builders/amazon#iam-task-or-instance-role](https://www.packer.io/docs/builders/amazon#iam-task-or-instance-role).
 
If running Packer from outside AWS (e.g. local system), you will need:
* AWS IAM user with programmatic access to use the AWS CLI, with access keys generated.
* AWS IAM role attached to IAM user (see above).
* AWS IAM access keys (<code>aws_access_key_id</code> and <code>aws_secret_access_key</code>) need to be configured on the system.
	* This can be done by setting them in the <code>~/.aws/credentials</code> file through the <code>aws configure</code> AWS CLI command **(recommended)** or set as environment variables in current shell (do not set globally in any shell rc or profile!).
