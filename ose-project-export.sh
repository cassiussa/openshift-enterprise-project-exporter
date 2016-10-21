#!/bin/sh
############################################################
##
## OpenShift Enterprise Project Exporter.  Performs regular
## export into yaml, 'raw' into yaml, and 'exact' into yaml
##
## Create a cronjob with the following, being sure to
## update the <EXPORT_DIR> folder to replicate the
## $EXPORT_DIR variable in the code below.
## 
## # Backup all the OSE Project config files to yaml, raw
## 0 1 * * * root <EXPORT_DIR>/project_export.sh > /dev/null
## 
## 
## Created by Cassius John-Adams cassius.s.adams@gmail.com
## https://github.com/cassiussa/openshift-enterprise-project-exporter
## 
############################################################

# MODIFY THESE VARIABLES
EXPORT_DIR=$(pwd)
GIT_BRANCH="master"
OSE_NAME="OpenShift Project Exporter"
OSE_EMAIL="openshift@osm101.dev.nm.cbc.ca"


##############################
## DON'T MODIFY BEYOND HERE ##
##############################

LOG_FILE="logs.txt"
if [ ! -f $LOG_FILE ]; then
    touch $LOG_FILE
fi

# Create the project_exports directory if it doesn't exist already
if [ ! -d $EXPORT_DIR ]; then
    mkdir $EXPORT_DIR
fi

cd $EXPORT_DIR

# Backup IFS
OLDIFS=$IFS
# Create an array of the Projects in OpenShift Enterprise 
IFS=$'\n' command eval "PROJECTS=($(oc get project | awk 'FNR>1 {print $1}'))"

# Iterate throught eh array of Projects and export to yaml
for PROJECT in ${PROJECTS[@]}; do
    GLOG=$(oc project $PROJECT)
    echo "$(date) : $GLOG" >> $LOG_FILE
    oc export svc,sa,dc,bc,route,rc,is,templates -o yaml --exact > ${EXPORT_DIR}/${PROJECT}_exact.yaml
    oc export svc,sa,dc,bc,route,rc,is,templates -o yaml --raw > ${EXPORT_DIR}/${PROJECT}_raw.yaml
    oc export svc,sa,dc,bc,route,rc,is,templates -o yaml > ${EXPORT_DIR}/${PROJECT}_for_import.yaml
done

# We cache the current Git username and email so we can revert afterwards
GIT_USER=$(git config user.name)
GIT_EMAIL=$(git config user.email)

# Perform the Git commit and push it to the repository
git config --global user.name "$OSE_NAME"
git config --global user.email "$OSE_EMAIL"
GLOG=$(git add . 2>&1)
echo "$(date) : $GLOG" >> $LOG_FILE
GLOG=$(git commit -am "OpenShift project auto-export." 2>&1)
echo "$(date) : $GLOG" >> $LOG_FILE
GLOG=$(git push origin $GIT_BRANCH 2>&1)
echo "$(date) : $GLOG" >> $LOG_FILE

# Return to original Git user values
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"


