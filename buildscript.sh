#!/bin/bash
SERVICE_NAME="sample-nodejs-app-service"
IMAGE_VERSION="v_"${BUILD_NUMBER}
TASK_FAMILY="sample-nodejs-app-task"
CLUSTER="sample-nodejs-app-cluster"

# Create a new task definition for this build
sed -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" mytaskdef.json > mytaskdef-v_${BUILD_NUMBER}.json
aws ecs register-task-definition --family $TASK_FAMILY --cli-input-json file://mytaskdef-v_${BUILD_NUMBER}.json

# Update the service with the new task definition and desired count
TASK_REVISION=`aws ecs describe-task-definition --task-definition $TASK_FAMILY | egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/,$//'`
DESIRED_COUNT=`aws ecs describe-services --cluster $CLUSTER --services ${SERVICE_NAME} | egrep "desiredCount" | head -n 1 | tr "/" " " | awk '{print $2}' | sed 's/,$//'`
if [ ${DESIRED_COUNT} = "0" ]; then
    DESIRED_COUNT="1"
fi

aws ecs update-service --cluster $CLUSTER --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count ${DESIRED_COUNT}

