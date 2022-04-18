#!/bin/bash

#
# ビルドとデプロイ (aws 定義の作成) までを実行します。
#

set -x

[ -z "$STACK_NAME" ] && echo "Please specify STACK_NAME environment variable" && exit 1;
[ -z "$AWS_DEFAULT_REGION" ] && echo "Please specify AWS_DEFAULT_REGION environment variable" && exit 1;

sam build --use-container
sam deploy --guided --stack-name $STACK_NAME

echo -e "\nWhen you have finished creating the CloudFormation stack, Run deploy-2.sh."
