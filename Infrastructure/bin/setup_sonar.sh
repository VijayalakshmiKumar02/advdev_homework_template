#!/bin/bash
# Setup Sonarqube Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Sonarqube in project $GUID-sonarqube"

# Code to set up the SonarQube project.
# Ideally just calls a template
# oc new-app -f ../templates/sonarqube.yaml --param .....

# To be Implemented by Student
oc project ${GUID}-sonarqube
oc new-app -f ./Infrastructure/templates/sonar_template.yaml --param GUID=${GUID} POSTGRESQL_USER=sonar --param POSTGRESQL_PASSWORD=sonar --param POSTGRESQL_DATABASE=sonar --param POSTGRESQL_VOLUME_CAPACITY=4Gi -n ${GUID}-sonarqube

#Recreate deployment strategy rather than the default Rolling deployment strategy.
oc set resources dc/sonarqube --limits=memory=3Gi,cpu=2 --requests=memory=2Gi,cpu=1 -n $GUID-sonarqube
oc patch dc sonarqube --patch='{ "spec": { "strategy": { "type": "Recreate" }}}' -n $GUID-sonarqube

#add liveness and readiness probes.
oc set probe dc/sonarqube --liveness --failure-threshold 3 --initial-delay-seconds 40 -- echo ok -n $GUID-sonarqube
oc set probe dc/sonarqube --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:9000/about -n $GUID-sonarqube

