#!/bin/bash
set -u

echo "### Create a Stack. ###"

export s3DomainName=s3.${Region}.amazonaws.com
echo "Region=${Region}"
echo "s3DomainName=${s3DomainName}"
echo "StackName=${StackName}"
echo "Template=https://${s3DomainName}/${S3ModulePath}/cfn/${Template}"
echo "Parameter=${WORKSPACE}/param/${Parameter}"

## Stackの存在確認
aws cloudformation describe-stacks --stack-name ${StackName} --region ${Region} >/dev/null 2>&1

## Stackの更新か作成か処理分岐
if [ $? -ne 0 ]; then
  aws cloudformation create-stack --stack-name ${StackName} \
    --template-url https://${s3DomainName}/${S3ModulePath}/cfn/${Template} \
    --parameters file://./param/${Parameter} \
    --tags Key=Owner,Value=awesome \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --disable-rollback \
    --region ${Region}
else
  aws cloudformation update-stack --stack-name ${StackName} \
    --template-url https://${s3DomainName}/${S3ModulePath}/cfn/${Template} \
    --parameters file://./param/${Parameter} \
    --tags Key=Owner,Value=awesome \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
    --region ${Region}
fi

## 実行結果確認
if [ "$?" -ne "0" ]; then
  echo "Stack created in the failure."
  exit 1
fi

echo "### StackName : ${StackName} ###"
echo "### Wait 1 minutes.. ###"
sleep 60

exit 0
