#!/bin/bash

# Script for packaging & Installation of Salesforce Unlocked Package

# Instructions:
#####################################################################################################################################
#   It also uses the CI environment
#   variable as safeguard for making sure that the script runs in the CI environment.

#   Note: When you create a new Package, also create an extra version before using this script. This script is for updates to package.

#   In Feature / Develop Branch
#   To create subsequent versions & install from a developer workstation assuming alias for his/her Scratch org is MyScratchOrg, run
#   cd/packagingDeployment.sh package MyScratchOrg

#   In Feature / Develop Branch
#   To install latest version from a developer workstation only (already defined in script below) to the scratch org, run
#   cd/packagingDeployment.sh install MyScratchOrg

#   In Package branch, 
#   1. Update PACKAGE_VERSION in this script as new stable version
#   2. Create a git tag with the version to trigger the UAT pipeline

#   Before promoting to Production (promote package version)
#   TODO: When running in Prod CD, promote the package version

#   While in CD branches, install (QA, UAT, Prod environment)
#   cd/packagingDeployment.sh
#####################################################################################################################################

# Package specific variables

# In CI-CD, the build folder becomes the working folder 
BUILD_NAME="ECFMG.ES-Base-Objects - CI"
PACKAGE_NAME="EzSpaceBaseObjects"
PACKAGE_VERSION="EzSpaceBaseObjects@0.1.0-8"

# Default values
ACTION=$1
SFDX_CLI_EXEC=sfdx
TARGET_ORG=''
PROJECT_HOME="$BUILD_NAME/package"

if [ "$#" -eq 0 ]; then
  echo "No parameter provided, this will be package installation to authenticated CD Org"
  echo "Current directory: ${PWD##*/}"
  # Change directory in Deployment pipeline
  cd "$PROJECT_HOME"
  echo "Current directory changed to: ${PWD##*/}"
  TARGET_ORG="-u CDOrg"
fi

# Used by package people for their own installation
if [ "$#" -eq 2 ]; then
  TARGET_ORG="-u $2"
  echo "Using specific org $2"
fi

# Reading the to be installed package version based on the alias@version key from sfdx-project.json
PACKAGE_VERSION="$(cat sfdx-project.json | jq --arg VERSION "$PACKAGE_VERSION" '.packageAliases | .[$VERSION]' | tr -d '"')"

# We're creating a new version
if [ "$ACTION" = "package" ]; then
  echo "Creating new package version for $PACKAGE_NAME"
  PACKAGE_VERSION="$($SFDX_CLI_EXEC force:package:version:create -p "$PACKAGE_NAME" -x -w 10 --json | jq '.result.SubscriberPackageVersionId' | tr -d '"')"
  sleep 500 # We've to wait for package replication.
fi

# Installation in dependency order
echo "Package installation: $PACKAGE_NAME $PACKAGE_VERSION"
$SFDX_CLI_EXEC force:package:install --package $PACKAGE_VERSION -w 10 $TARGET_ORG

#Deleting the Data from records (TODO: fails when record is in use)
echo "Deleting existing Static Data"
#sfdx force:apex:execute -f scripts/my-apex-test.txt

#Add the records back
#echo "Inserting new Static Data"
#sfdx force:data:tree:import --plan ./data/Plan1.json
#sfdx force:data:tree:import --plan ./data/Plan2.json

echo "Done"