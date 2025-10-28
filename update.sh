#!/bin/bash

set -e

DEBUG=""

if [ -z ${PLUGIN_ROLE} ]; then
  echo "You must specify a role to assume"
  exit 1
fi

if [ -z ${PLUGIN_CLUSTER} ]; then
  echo "You must specify a cluster name"
  exit 1
fi

if [[ -z ${PLUGIN_EXEC_COMMANDS} && -z ${PLUGIN_PREDEPLOY_TASKS} && -z ${PLUGIN_TASKS} && -z ${PLUGIN_SERVICES} ]]; then
  echo "You must specify either services, (predeploy_)tasks, or exec_commands (or several of them)"
  exit 1
fi

if [[ ! -z ${PLUGIN_EXEC_COMMANDS} && -z ${PLUGIN_EXEC_SERVICE} ]]; then
  echo "You must specify an execution service, when using commands"
  exit 1
fi

if [[ ( ! -z ${PLUGIN_TASKS} || ! -z ${PLUGIN_PREDEPLOY_TASKS} ) && -z ${PLUGIN_TASK_DEFINITION} ]]; then
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
exec_commands=($PLUGIN_EXEC_COMMANDS)
predeploy_tasks=($PLUGIN_PREDEPLOY_TASKS)
tasks=($PLUGIN_TASKS)

# Run commands
for command in "${!exec_commands[@]}"; do
  ecs-deploy $DEBUG --exec \
             -r ${PLUGIN_REGION} \
             -c ${PLUGIN_CLUSTER} \
             -i ${PLUGIN_IMAGE:-latest} \
             -t ${PLUGIN_TIMEOUT:-300} \
             -a ${PLUGIN_ROLE} \
             -s ${PLUGIN_EXEC_SERVICE} \
             -C "${exec_commands[$command]}"
done

# Run pre-deploy tasks
for command in "${!predeploy_tasks[@]}"; do
  ecs-deploy $DEBUG --wait \
             -r ${PLUGIN_REGION} \
             -c ${PLUGIN_CLUSTER} \
             -i ${PLUGIN_IMAGE:-latest} \
             -t ${PLUGIN_TIMEOUT:-300} \
             -a ${PLUGIN_ROLE} \
             -d ${PLUGIN_TASK_DEFINITION} \
             -C "${predeploy_tasks[$command]}"
done

pids=()

# Run one-off tasks
for command in "${!tasks[@]}"; do
  ecs-deploy $DEBUG \
             -r ${PLUGIN_REGION} \
             -c ${PLUGIN_CLUSTER} \
             -i ${PLUGIN_IMAGE:-latest} \
             -t ${PLUGIN_TIMEOUT:-300} \
             -a ${PLUGIN_ROLE} \
             -d ${PLUGIN_TASK_DEFINITION} \
             -C "${tasks[$command]}" &
  pids+=($!)
done


# Deploy services
for service in "${!services[@]}"; do
  ecs-deploy $DEBUG \
             -r ${PLUGIN_REGION} \
             -c ${PLUGIN_CLUSTER} \
             -i ${PLUGIN_IMAGE} \
             -t ${PLUGIN_TIMEOUT:-300} \
             -a ${PLUGIN_ROLE} \
             -s ${services[$service]} &
  pids+=($!)
done

echo "Waiting for all background processes to finish..."
for pid in "${pids[@]}"; do
  wait "${pid}"
done

echo "All commands have been executed."
