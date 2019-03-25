# This bash script will be used by "Bash Script" Release Task in Azure DevOps for all the environments
#!/bin/bash
echo "Exporting Variables:"
export URL=https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-amd64.tar.xz
export SFDX_AUTOUPDATE_DISABLE=false
export SFDX_USE_GENERIC_UNIX_KEYCHAIN=true
export SFDX_DOMAIN_RETRY=300
export SFDX_DISABLE_APP_HUB=true
export SFDX_LOG_LEVEL=DEBUG
export buildVersion=$BUILD_SOURCEBRANCHNAME
version=${buildVersion:1}
echo $URL
echo $version
echo 
echo "Making sfdx Directory:"
mkdir sfdx
echo "downloading Salesforce DX:"
#wget -qO- $URL | tar xJf -C sfdx --strip-components=1
#wget -qO- $URL
wget https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-amd64.tar.xz 
echo "Unzipping Salesforce DX:"
tar xJf sfdx-linux-amd64.tar.xz -C sfdx --strip-components=1
echo "Installing Salesforce DX:"
"./sfdx/install"
export PATH=./sfdx/$(pwd):$PATH
sfdx --version
sfdx plugins --core
echo 
echo "Authenticating with Salesforce Org:"
sfdx force:auth:jwt:grant --clientid $APP_CONSUMER_KEY --username $APP_USERNAME --jwtkeyfile $AGENT_TEMPDIRECTORY/server.key --setdefaultusername -a CDOrg 
echo 
echo "Displaying Org Info:"
sfdx force:org:list --verbose
sfdx force:org:display -u CDOrg 