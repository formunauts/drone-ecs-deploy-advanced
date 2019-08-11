#!/bin/bash

DEBUG=""

if [ -z ${PLUGIN_ROLE} ]; then
  echo "You must specify a role to assume"
  exit 1
fi

if [ -z ${PLUGIN_CLUSTER} ]; then
  echo "You must specify a cluster name"
  exit 1
fi

if [[ -z ${PLUGIN_SERVICES} && -z $PLUGIN_TASKS ]]; then
  echo "You must specify either services, tasks or both"
  exit 1
fi

if [[ ! -z ${PLUGIN_TASKS} && -z ${PLUGIN_TASK_DEFINITION} ]]; then
  echo "You must specify a task definition, when using tasks"
  exit 1
fi

if [ -z ${PLUGIN_REGION} ]; then
  PLUGIN_REGION="eu-central-1"
fi

if [ "${PLUGIN_DEBUG}" == "true" ]; then
  DEBUG="--debug"
fi

IFS=','
services=($PLUGIN_SERVICES)
tasks=($PLUGIN_TASKS)

# Run one-off tasks
for command in "${!tasks[@]}"; do
  ecs-deploy $DEBUG \
             -r ${PLUGIN_REGION} \
             -c ${PLUGIN_CLUSTER} \
             -i ${PLUGIN_IMAGE:-latest} \
             -t ${PLUGIN_TIMEOUT:-300} \
             -a ${PLUGIN_ROLE} \
             -d ${PLUGIN_TASK_DEFINITION} \
             -C "${tasks[$command]}"
done


# Deploy services
for service in "${!services[@]}"; do
  ecs-deploy $DEBUG \
             -r ${PLUGIN_REGION} \
             -c ${PLUGIN_CLUSTER} \
             -i ${PLUGIN_IMAGE} \
             -t ${PLUGIN_TIMEOUT:-300} \
             -a ${PLUGIN_ROLE} \
             -s ${services[$service]}
done
