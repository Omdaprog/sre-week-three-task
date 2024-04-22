#!/bin/bash

if [[ -z $1  ||  -z $2 ]]
  then
    echo "ERROR: namespace and deployment are mandatory arguments. Example: watcher.sh sre swype-app";
    exit 1;
fi

# Name of the namespace received as parameter
NAMESPACE=$1

# Name of the deployment received as parameter
DEPLOYMENT=$2

# Maximum number of restarts before scaling down
MAX_RESTARTS=4

while true; do
  # Get the number of restarts of the pod
  RESTARTS=$(kubectl get pods -n ${NAMESPACE} -l app=${DEPLOYMENT} -o jsonpath="{.items[0].status.containerStatuses[0].restartCount}")

  echo "Current number of restarts: ${RESTARTS}"

  # If the number of restarts is greater than the maximum allowed, scale down the deployment
  if (( RESTARTS > MAX_RESTARTS )); then
    echo "Maximum number of restarts exceeded. Scaling down the deployment..."
    kubectl scale --replicas=0 deployment/${DEPLOYMENT} -n ${NAMESPACE}
    break
  fi

  # Wait for a while before the next check
  sleep 10
done
