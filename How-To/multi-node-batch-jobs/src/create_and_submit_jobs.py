from __future__ import print_function
import boto3
import traceback
import datetime
import numpy as np

batch_client = boto3.client('batch')

# Definition of parameters + evironment variables passed to the containers
num_jobs = 1
bucket = 'slim-bucket-common'
script_path = 'pwitte/scripts/'
script_name = 'mpi_example.py'
num_retry = 2
num_cores = 24
memory = 12000
container = 'philippwitte/test_multi_node_batch:v0.2'
batch_queue = 'TTI_SingleR5_24xlarge'
omp_places = 'cores'
instance_type = 'r5.24xlarge'
num_nodes = 2

# Register job definition
job_def = batch_client.register_job_definition(
    jobDefinitionName='multi_node_job_definition',
    type='multinode',
    nodeProperties={
        'numNodes': num_nodes,
        'mainNode': 0,
        'nodeRangeProperties': [
            {
                'targetNodes': '0:' + str(num_nodes-1),
                'container': {
                    'image': container,
                    'vcpus': num_cores,
                    'memory': memory,
                    'environment': [
                        {
                            'name': 'S3_BUCKET',
                            'value': bucket
                        },
                        {
                            'name': 'SCRIPT_PATH',
                            'value': script_path
                        },
                        {
                            'name': 'SCRIPT_NAME',
                            'value': script_name
                        },
                        {
                            'name': 'OMP_PLACES',
                            'value': omp_places
                        },
                        {
                            'name': 'NUM_CORES',
                            'value': str(num_cores)
                        },
                    ],
                    'volumes': [
                        {
                            'host': {
                                'sourcePath': '/efs'
                            },
                            'name': 'efs'
                        },
                    ],
                    'mountPoints': [
                        {
                            'containerPath': '/efs',
                            'sourceVolume': 'efs'
                        },
                    ],
                    'instanceType': instance_type
                }
            },
        ]
    },
    retryStrategy={
        'attempts': num_retry
    }
)

# Submit job
revision = job_def['revision']
response = batch_client.submit_job(
    jobName='multi-node-batch-job',
    jobQueue=batch_queue,
    jobDefinition='multi_node_job_definition:' + str(revision)
)
