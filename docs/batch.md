
# Batch environment

This tutorial demonstrates how to run multi-node batch jobs on Amazon Web Services. Standard AWS Batch allows processing of embarassingly parallel workloads using containerization. Jobs are processed from a batch queue in parallel as individual docker containers. In the standard setting, each container runs on a single EC2 instance and no communication between jobs and/or workers is possible. Multi-node Batch jobs are an extension of concept, in which it is possible to use multiple EC2 instances per job, where instances communicate via the network.

To run AWS Batch jobs, we need to first set up *Compute environments* and *Job queues*. The compute environments essentially specify the virtual cluster that AWS Batch has access to. This involves specifying which type of instances are allowed, as well as their size (i.e. the number of available CPUs and memory). For multi-node AWS Batch jobs, we also have to set up a shared file system and a customized Amazon Machine Image (AMI).

## Prerequisites

Before you can proceed, make sure you have all necessary AWS user and service roles in place. Follow this link to the documentation for creating all necessary user roles.

## Elastic file system

For multi-node AWS Batch jobs, we need to set up a shared file system called *elastic file system* (EFS). Furthermore, we need to set up a customized Amazon Machine Image (AMI) and mount the shared file system. Detailed instructions for these steps are provided in the AWS documentation: <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_efs.html>. Here, we provide a summary of the necessary steps:

1) Create an elastic file system by logging into the AWS console in the web browser and go to `Services` -> `EFS` -> `Create file system`. By default, AWS will fill in all available subnets and include the default security group. For each zone, also add the SSH-security group. Proceed to step 2 and 3 and then select `Create File System`.

2) Next, we have to modify the AMI that is used by AWS Batch and mount the file system. For this, we launch an EC2 instances with the ECS-optimized AMI, mount the EFS and create a custom AMI, which will then be used in the compute environment.

Choose the Amazon Linux 2 AMI for your region from the following list:
<https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html>. For example, for the `us-east-1` region, this is AMI ID `ami-0fac5486e4cff37f4`. Click on `Launch Instance` to request an EC2 instance with the corresponding AMI. Using the `t2.micro` instance type is sufficient for this task. Next, connect to your instance via `ssh`:

```
ssh -Y -i ~/.ssh/user_key_pair -o StrictHostKeyChecking=no -l ec2-user public_DNS_of_instance
```

Once you are logged into the instance, following the subsequent steps:

- Create mount point: `sudo mkdir /efs`

- Install the amazon-efs-utils client software: `sudo yum install -y amazon-efs-utils`

- Make a backup of the `/etc/fstab` file: `sudo cp /etc/fstab /etc/fstab.bak`

- Open the original file with `sudo vi /etc/fstab` and add the following line to it. Replace `efs_dns_name` with the DNS name of your elastic file system (find the DNS name in the AWS console -> `Services` -> `EFS` -> `name-of-your-file-system` -> `DNS name`):

```
efs_dns_name:/ /efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0

```

- Reload file system: `sudo mount -a`

- Validate that file system is mounted correctly: `mount | grep efs`


Log out from the instance and create a new AMI from the running EC2 instance. Go the list of running EC2 instances in the AWS console and select your running instance -> `Actions` -> `Image` -> `Create Image`. Choose an image name and then hit `Create Image`.


## AMIs without hyper-threading

By default, AWS Batch uses hyperthreading (HT) on the underlying EC2 instances. For certain applications, it is desirable to disable HT and to limit the number of cores to half the number of virtual CPU cores on the corresponding EC2 instance. For example, the `r5.24xlarge` instance has 96 virtual CPUs and therefore 48 physical cores. To disable HT for this instance, we need to set the maximum number of allowed CPUs to 48.

To disable HT, we modify the AMI that is used by AWS Batch. For this, we launch an EC2 instances with the ECS-optimized AMI, specify the maximum number of allowed CPUs and create a custom AMI. This AMI will then be used in the compute environment.

If you already created an AMI in the previous section with an elastic file system, start a new EC2 instance using this AMI and connect to your instance. If you have not created an AMI yet, choose the Amazon Linux 2 AMI for your region from the following list:
<https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html>. For example, for the `us-east-1` region, this is AMI ID `ami-0fac5486e4cff37f4`. Click on `Launch Instance` to request an EC2 instance with the corresponding AMI. Using the `t2.micro` instance type is sufficient for this task. Next, connect to your instance via `ssh`:

```
ssh -Y -i ~/.ssh/user_key_pair -o StrictHostKeyChecking=no -l ec2-user public_DNS_of_instance
```

Open the grub config file with `sudo vi /etc/default/grub` and add `nr_cpus=48` to the line starting with `GRUB_CMDLINE_LINUX` (or however many cores are required). Apply the changes by running:

```
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

Log out from the instance and create a new AMI from the running EC2 instance. Go the list of running EC2 instances in the AWS console and select your running instance -> `Actions` -> `Image` -> `Create Image`. Choose an image name that indicates the maximum number of cores and then hit `Create Image`.

Follow the same steps to create customized AMIs for other instance types with a differet number of CPU cores. E.g. for the `r5.12xlarge` instance, set `nr_cpus=24`, as this instance type has 48 vCPUs with 24 physicsal cores. For the `c5n.18xlarge` instance (72 vCPUs), set `nr_cpus=36` and so on.


## Create environments

Compute environments define the type of instances and the number of cores that are available for AWS Batch jobs. In this example, we set up a compute environment with `r5` instances, which are Amazon's memory optimized instances, but the instructions can be modified to include other instance types.

The compute environment can be set up from the command line, with all parameters being specified in the `~/Pre_Built_Tools-for-Amazon-AWS/How-To/multi-node-batch-jobs/setup/create_environment_r5_multinode_24.json` file. Open the file and fill in **all missing entries**. These are:

 - `spotIamFleetRole`: Go to the AWS console -> `Services` -> `IAM` -> `Roles` and find the `AmazonEC2SpotFleetRole`. Copy the role ARN and paste it.

 - `subnets`:  Find your subnets in the AWS console at `Services` -> `VPC` -> `Subnets`. Copy the Subnet ID of each subnet into the parameter file (separated by commas).

 - `securityGroupIds`: Find the security groups in the console at `Services` -> `EC2` -> `Security groups`. Copy-paste the Group ID of the default security group. To enable ssh access to instances of AWS Batch jobs, optionally create and add an SSH security group to this list.

 - `ec2KeyPair`: To connect to running instances via ssh, add the name of your AWS ssh key pair.

 - `imageId`: Go to the console -> `Services` -> `EC2` -> `AMIs` and find the AMI that was created in the previous step. For the `M4_SPOT_MAXCPU_8` compute environment, find the AMI with 8 cores and copy-paste the AMI-ID into the parameter file.

 - `instanceRole`: Go to the AWS console -> `Services` -> `IAM` -> `Roles`. Find the `Service-Role_ECS_for_EC2` role and add its ARN to the parameter file.


 - `serviceRole`: Go to the AWS console -> `Services` -> `IAM` -> `Roles`. Find the `AWSBatchServiceRole` role and add its ARN.

The parameter files also specify a placement group called `MPIgroup`. The placement group ensures that EC2 instances of the MPI clusters are in close physical vicinity to each other. Create the `MPIgroup` placement group from the AWS console `Services` -> `EC2` -> `Placement Groups` -> `Create Placement Group`. Enter the name `MPIgroup` and select `Cluster` in the `Strategy` field. Then click the `create` button.

Do not modify the parameters that are already filled in. Save the updated file and then run the following command within the `~/Pre_Built_Tools-for-Amazon-AWS/How-To/multi-node-batch-jobs` directory:

```
# Create environment
aws batch create-compute-environment --cli-input-json file://setup/create_environment_r5_multinode_24.json
```

You can go to the AWS Console in the web browser and move to `Services` -> `AWS Batch` -> `Compute environments` to verify that the environment has been created successfully.


## Create queues

For each compute environment, we need to create an AWS Batch Job queue, to which jobs can be submitted. The queue parameter files do not need to be modified, so simply run the following commands from the terminal within the `~/Pre_Built_Tools-for-Amazon-AWS/How-To/multi-node-batch-jobs` directory:

```
# Job queue r5 on-demand
aws batch create-job-queue --cli-input-json file://setup/create_queue_r5_multinode_24.json

```

## VPC endpoints

For multi-node batch jobs, follow these steps to create an endpoint for S3 in your virtual privat cloud:

 - Log into the AWS console in the browser and go to: `Services` -> `VPC` -> `Endpoints`.

 - Create an S3 endpoint: click `Create Endpoint` and select the S3 service name from the list, e.g. `com.amazonaws.us-east-1.s3`. Next, select the only available route table in the section `Configure route tables`. Finalize the endpoint by clicking the `Create Endpoint` button.


## Docker

AWS Batch runs jobs inside Docker containers and for multi-node batch jobs, the containers need to set up the MPI environment. Once a multi-node batch jobs starts, the containers must establish a network connection via ssh, before being able to run the application. The Dockerfile in `How-To/multi-node-batch-jobs/src/Dockerfile` can be used as a template to build custom Docker container for any application. The container is based on an Ubuntu image and contains all necessary components to establish the MPI environment during runtime.

To create a Docker container for multi-node batch jobs from the Dockerfile, run the following command, using a valid tag for the Docker image (e.g. `v1.1`):

```
cd ~/Pre_Built_Tools-for-Amazon-AWS/How-To/multi-node-batch-jobs/src
docker build -t aws_multi_node_batch:tag .
```

You can upload the Docker image to your personal Docker hub or to your personal AWS account. For the latter case, you first need to obtain login credentials by AWS. Copy-paste the output of the following command back into the terminal:

```
# Get ECR login credentials and use the token that is printed in the terminal
aws ecr get-login --no-include-email
```

If the log in was successful, you will see the message "Login Succeeded" in your terminal. Next, create a repository on AWS called `aws_multi_node_batch`:

```
# Create repository (only first time)
aws ecr create-repository --repository-name aws_multi_node_batch
```

Now, tag the new image using the URI of the repository that you just created. To find the URI of your repository, go to the AWS console -> `Services` -> `ECR` -> `aws_multi_node_batch`. Tag your image by running:

```
# tag image
docker tag aws_multi_node_batch:tag URI:tag
```

Finally, upload your Docker image to your AWS container registry:

```
docker push URI:tag
```

Note the full name of your new image (`URI:tag`) for the subsequent steps.


## Submitting a multi-node batch job

Once you successfully created and uploaded your Docker container and completed all previous steps, you can finally submit a multi-node AWS Batch job. There are several possibilities for submitting jobs:

- Create and submit jobs from the AWS console in the web browser

- Create and submit jobs from the command line using the AWS CLI

- Create and submit jobs from Python using the `boto3` package.

Here, we will walk you through the third option, as it is the easiest option to reproduce. The file `How-To/multi-node-batch-jobs/example/create_and_submit_job.py` contains a template to you can modify for your purposes. The file contains the following steps:

1. Definition of job parameters. Fill in all missing entries in the script.

2. Creating a job definition. This is essentially a job template and specifies the number of nodes per job, as well as the environment variables. You don not need to modify this part.

3. Submitting the job. Using the job definition from the previous step, you submit the AWS Batch job.

Before running the script, you have to upload our example application `mpi_example.py` (under `How-To/multi-node-batch-jobs/example/`) to an S3 bucket. Note the name of the bucket and the S3 path to your script and fill in the corresponding entries into the `create_and_submit_job.py` script. Running the script will add the job to the AWS Batch queue. You can go to the console in the webbrowser and check the status of your job under `AWS Batch` -> `Jobs` -> `MultiNodeQueue_R5_MAX_24` -> `Runnable`. Click on the job ID and go to the `Nodes` tab. Once your job is scheduled, it will appear under `Starting`.
