# Pre-built Tools for Amazon Web Services

This repository contains a collection of tools to run serverless computations and parallel batch jobs on AWS.


## Necessary AWS credentials

The tools in this repository require access to the **IAM user name** and password (to log into the AWS console), as well as to the **AWS Access Key ID** and the **AWS Secret Access key**.

## Install and configure AWS Command Line Interface

The first required step is the installation of the AWS command line interface (CLI). With `pip3`, the CLI can be installed from a Linux/Unix terminal by executing the following command:

```
pip3 install awscli --upgrade --user
```

Once installed, the CLI must be configured with the AWS user credentials. Run `aws configure` from the command line and enter your AWS Access Key ID, the AWS Secret Access Key and a region name (e.g. `us-east-1`).


## Clone github repository

Next, clone the Github repository that contains all setup scripts and the numerical examples. Here, we add the repository to the home directory (`~/`):

```
git clone https://github.com/HARC-PTI/Pre_Built_Tools-for-Amazon-AWS ~/.
```

## Contributing authors

 - Philipp Witte, Georgia Institute of Technology. All content copyrighted by the Georgia Institute of Technology, 2019.
