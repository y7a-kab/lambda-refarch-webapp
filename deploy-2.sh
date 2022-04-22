#!/bin/bash

#
# デプロイ後に Amplify 用の config を作成して commit / push します。
# push 後に Amplify コンソールでアプリをビルドしてください。
#

set -x

# export AWS_COGNITO_REGION=$AWS_DEFAULT_REGION

# [ -z "$STACK_NAME" ] && echo "Please specify STACK_NAME environment variable" && exit 1;
if [ -z "$STACK_NAME" ]; then
    export STACK_NAME=$(basename $(cd $(dirname $0); pwd))
    echo "CloudFormation Default Stack Name: ${STACK_NAME}"
fi

export AWS_USER_POOLS_WEB_CLIENT_ID=`aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='CognitoClientID'].OutputValue" --output text`
[ -z "$AWS_USER_POOLS_WEB_CLIENT_ID" ] && echo "Can not retrive CognitoClientID." && exit 1;

export API_BASE_URL=`aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='TodoApiUrl'].OutputValue" --output text`
[ -z "$API_BASE_URL" ] && echo "Can not retrive TodoApiUrl." && exit 1;

export STAGE_NAME_PARAM=`aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Parameters[?ParameterKey=='StageName'].ParameterValue" --output text`
[ -z "$STAGE_NAME_PARAM" ] && echo "Can not retrive StageName." && exit 1;

export COGNITO_HOSTED_DOMAIN=`aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='CognitoDomainName'].OutputValue" --output text`
[ -z "$COGNITO_HOSTED_DOMAIN" ] && echo "Can not retrive CognitoDomainName." && exit 1;

export REDIRECT_URL=`aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='AmplifyURL'].OutputValue" --output text`
[ -z "$REDIRECT_URL" ] && echo "Can not retrive AmplifyURL." && exit 1;

cp www/src/config.default.js www/src/config.js
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' -e 's/AWS_USER_POOLS_WEB_CLIENT_ID/'"$AWS_USER_POOLS_WEB_CLIENT_ID"'/g' www/src/config.js
  sed -i '' -e 's/API_BASE_URL/'"${API_BASE_URL//\//\\/}"'/g' www/src/config.js
  sed -i '' -e 's/{StageName}/'"$STAGE_NAME_PARAM"'/g' www/src/config.js
  sed -i '' -e 's/COGNITO_HOSTED_DOMAIN/'"$COGNITO_HOSTED_DOMAIN"'/g' www/src/config.js
  sed -i '' -e 's/REDIRECT_URL/'"${REDIRECT_URL//\//\\/}"'/g' www/src/config.js
else
  sed -i -e 's/AWS_USER_POOLS_WEB_CLIENT_ID/'"$AWS_USER_POOLS_WEB_CLIENT_ID"'/g' www/src/config.js
  sed -i -e 's/API_BASE_URL/'"${API_BASE_URL//\//\\/}"'/g' www/src/config.js
  sed -i -e 's/{StageName}/'"$STAGE_NAME_PARAM"'/g' www/src/config.js
  sed -i -e 's/COGNITO_HOSTED_DOMAIN/'"$COGNITO_HOSTED_DOMAIN"'/g' www/src/config.js
  sed -i -e 's/REDIRECT_URL/'"${REDIRECT_URL//\//\\/}"'/g' www/src/config.js
fi

git checkout "amp-build"
[ $? -ne 0 ] && echo "Can not checkout amp-buid branch." && exit 1;

git add www/src/config.js
git commit -m 'Frontend config update'
git push

echo -e "\nBuild your application with the exploit console."
