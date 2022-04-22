#!/bin/bash

#
# ビルドとデプロイ (aws 定義の作成) までを実行します。
#

set -x

[ -z "$AWS_DEFAULT_REGION" ] && echo "Please specify AWS_DEFAULT_REGION environment variable" && exit 1;

# [ -z "$STACK_NAME" ] && echo "Please specify STACK_NAME environment variable" && exit 1;
if [ -z "$STACK_NAME" ]; then
    export STACK_NAME=$(basename $(cd $(dirname $0); pwd))
    echo "CloudFormation Default Stack Name: ${STACK_NAME}"
fi

sam build --use-container

sam deploy --guided --stack-name ${STACK_NAME}

echo -e "\nWhen you have finished creating the CloudFormation stack, Run deploy-2.sh."
