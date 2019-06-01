#!/bin/bash
export USERID=$(id -u)
export PATH="$PATH:/usr/local/bin"
export GROUPID=$(id -g)
cd $(dirname $0)
export NEXUS_REPO=snapshots
docker-compose -f test-bed.yml run --rm -w "$WORKSPACE" --name maven-${BUILD_NUMBER} -e NEXUS_REPO=$NEXUS_REPO --entrypoint "SBI/runtests.sh" maven-app-build
