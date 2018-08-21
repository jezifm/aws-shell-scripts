#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if [[ $# -lt 2 ]] ; then
    echo $0' "{Project Name}" {project-slug}'
    exit 0
fi

PROJECT_NAME=$1
PROJECT_SLUG=$2
VPC_ID=$(aws ec2 describe-vpcs --output text --query "Vpcs[0].VpcId")
CIDR=0.0.0.0/0
SECURITY_GROUP_NAME=security-group-$PROJECT_SLUG
SECURITY_GROUP_DESCRIPTION="Security group for $PROJECT_NAME environment"
KEY_NAME=$PROJECT_SLUG-key
KEY_FILENAME=$KEY_NAME.pem
KEY_PATH="$HOME/.ssh/$KEY_FILENAME"
INSTANCE_PROFILE_NAME=$PROJECT_SLUG-profile


aws ec2 create-security-group \
    --group-name $SECURITY_GROUP_NAME \
    --vpc-id $VPC_ID \
    --description "$SECURITY_GROUP_DESCRIPTION"

aws ec2 authorize-security-group-ingress\
    --group-name $SECURITY_GROUP_NAME \
    --protocol tcp \
    --port 22 \
    --cidr $CIDR

aws ec2 create-key-pair \
    --key-name $KEY_NAME \
    --query 'KeyMaterial' \
    --output text > $KEY_PATH
chmod 400 $KEY_PATH
