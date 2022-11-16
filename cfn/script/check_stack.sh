#!/bin/bash
set -u

echo "### Check the status of the Stack. ###"
## Stackの状態確認
while :; do
  STACK_STATUS=$(aws cloudformation describe-stacks \
    --stack-name ${StackName} \
    --query 'Stacks[].StackStatus' \
    --output text \
    --region ${Region})
  echo "$(date +"%Y/%m/%d %H:%M:%S(UTC)") Status: ${STACK_STATUS}"

  ## Stackの状況出力
  aws cloudformation describe-stack-events \
    --stack-name ${StackName} \
    --query StackEvents[].[LogicalResourceId,ResourceStatus,Timestamp,ResourceStatusReason] \
    --max-items 20 \
    --region ${Region} \
    --output table

  ## Stackの作成状況確認
  case $STACK_STATUS in
  CREATE_COMPLETE | UPDATE_COMPLETE) break ;;
  *IN_PROGRESS*)
    echo "### Wait 1 minutes.. ###"
    sleep 60
    ;;
  *) exit 1 ;;
  esac
done
