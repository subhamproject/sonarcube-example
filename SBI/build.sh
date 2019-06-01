#!/bin/bash

export PATH="$PATH:/usr/local/bin"
export USERID=$(id -u)
export GROUPID=$(id -g)
echo "Running as UID=$USERID, GID=$GROUPID on branch $BRANCH_NAME"
cd $(dirname $0)
export NEXUS_REPO=snapshots 
docker-compose -f test-bed.yml run --name maven-${BUILD_NUMBER} --rm -w "$WORKSPACE" -e NEXUS_REPO=$NEXUS_REPO --entrypoint "mvn -s settings.xml clean package" maven-app-build
