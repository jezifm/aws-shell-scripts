#!/usr/bin/env bash
# Scripts uses default VPC and Subnet
set -eo pipefail
IFS=$'\n\t'



while getopts ":i:p:" opt; do
  case $opt in
    i) IP_ADDRESS="$OPTARG"
    ;;
    p) PROJECT_SLUG="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done


if [[ -z "${PROJECT_SLUG}" ]]; then
    echo 'Usage: '
    echo '    ./run_instance.sh -p {project-slug}'
    echo ''
    echo 'Flags (optional):'
    echo '    -i {public-ip-address}'
    exit 0
fi


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
    $([[ -n "$IP_ADDRESS" ]] && echo "--associate-public-ip-address $IP_ADDRESS") \
    --query 'Instances[0].InstanceId'
