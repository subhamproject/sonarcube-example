#!/bin/bash
#mvn -U -s settings.xml -Dmaven.package.skip=true -Dmaven.test.skip=true -Dmaven.compile.skip=true deploy
mvn -U -s settings.xml -Dmaven.package.skip=true -Dmaven.test.skip=true -Dmaven.compile.skip=true deploy sonar:sonar -Dsonar.host.url=http://13.229.133.70:9000 -Dsonar.login=$SONAR_TOKEN -Dsonar.projectName=sonar-report
