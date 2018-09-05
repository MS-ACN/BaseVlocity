#!/usr/bin/env bash 
set -e
set -x

# Must Run NPM Install before running script. But not every time it is run locally. 
# In a Jenkins Org npm install may need to be run earlier to Authenticate to the your Environment Hub
#npm install

# As Documented in the README.md a CI Server like Jenkins would also need to Authorize SFDX like:
# sfdx force:auth:jwt:grant --username "$DP_BT_HUB" --jwtkeyfile "$DP_BT_JWT" --clientid "$DP_DT_CONNECTED" --setdefaultdevhubusername

# Change how long the Scratch Org will last. Max: 30
DURATION_DAYS=1

# Create Scratch Org if no Username provided as first argument - "./deployProject.sh username@test.com"
if [ -z "$1" ]; then
    SCRATCH_ORG=`sfdx force:org:create --definitionfile config/scratch.json --durationdays $DURATION_DAYS --json`
    SF_USERNAME=`echo $SCRATCH_ORG | jq -r '. | .result.username'`
else 
    SF_USERNAME=$1
fi

# Install or Update Managed Package - Will finish quickly when already correct version
sfdx force:mdapi:deploy --deploydir managed_packages/vlocity_cmt --wait -1 --targetusername $SF_USERNAME

# Push Salesforce part of Project
sfdx force:source:push --targetusername $SF_USERNAME

# Update Settings
vlocity -sfdx.username $SF_USERNAME -job VlocityBase.yaml packUpdateSettings

# This project is comprised of the Vlocity Managed Package DataPacks usually installed 
# through the Cards and Templates UIs. However if you had a project with your own 
# DataPacks and wanted to install the current Managed Package version of those files through 
# this tool, then you can use "refreshVlocityBase". However it is important only to run this 
# on new Orgs as it is the default data for many Vlocity DataPacks including EPC Object Classes.
# Command:
# vlocity -sfdx.username $SF_USERNAME -job VlocityBase.yaml refreshVlocityBase

# Deploy vlocity_base folder
vlocity -sfdx.username $SF_USERNAME -job VlocityBase.yaml packDeploy

# Check that vlocity_base DataPacks are identical in Org as ones deployed / local
vlocity -sfdx.username $SF_USERNAME -job VlocityBase.yaml packGetDiffsCheck