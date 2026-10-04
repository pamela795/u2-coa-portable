#!/bin/bash
set -e
CLUSTER_NAME="u2-coa-local"
if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    echo "Deleting cluster $CLUSTER_NAME..."
    k3d cluster delete "$CLUSTER_NAME"
else
    echo "Cluster not found, nothing to do."
fi
