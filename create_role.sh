#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'


if [[ $# -eq 0 ]] ; then
    echo 'Usage: ./create_role.sh {project-slug}'
    exit 0
fi


PROJECT_SLUG=$1
ROLE_NAME=$PROJECT_SLUG-role
POLICY_NAME=$PROJECT_SLUG-policy
INSTANCE_PROFILE_NAME=$PROJECT_SLUG-profile


aws iam create-role \
    --role-name $ROLE_NAME \
    --assume-role-policy-document file://ec2-role-trust-policy.json

aws iam put-role-policy \
    --role-name $ROLE_NAME \
    --policy-name $POLICY_NAME \
    --policy-document file://ec2-role-access-policy.json

aws iam create-instance-profile \
    --instance-profile-name $INSTANCE_PROFILE_NAME

aws iam add-role-to-instance-profile \
    --instance-profile-name $INSTANCE_PROFILE_NAME \
    --role-name $ROLE_NAME
