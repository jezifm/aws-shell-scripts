#!/usr/bin/env bash
# Scripts uses default VPC and Subnet
set -euo pipefail
IFS=$'\n\t'

# Usage
if [[ $# -eq 0 ]] ; then
    echo 'Usage: '
    echo '    ./run_instance.sh {project-slug}'
    exit 0
fi

PROJECT_SLUG=$1
VPC_ID=$(aws ec2 describe-vpcs --output text --query "Vpcs[0].VpcId")
IMAGE_ID=ami-08569b978cc4dfa10 # TODO: automate
INSTANCE_TYPE=t2.micro
SUBNET_ID=$(aws ec2 describe-subnets --output text --filter Name=vpc-id,Values=$VPC_ID --query "Subnets[0].SubnetId")
SECURITY_GROUP_NAME=security-group-$PROJECT_SLUG
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --query 'SecurityGroups[?GroupName==`'$SECURITY_GROUP_NAME'`].GroupId' --output text)
KEY_NAME=$PROJECT_SLUG-key
INSTANCE_PROFILE_NAME=$PROJECT_SLUG-profile

aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --subnet-id $SUBNET_ID \
    --security-group-ids $SECURITY_GROUP_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --iam-instance-profile Name=$INSTANCE_PROFILE_NAME \
    --query 'Instances[0].InstanceId'
