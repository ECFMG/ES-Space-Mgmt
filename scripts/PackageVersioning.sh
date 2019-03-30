#!/bin/bash

#Before Versioning the package, update the fields below to reflect the current version, and package.
 

version_number = "1.0.0"

version_name = "Version 1.0"

target_dev_hub_username = "devhub"

package = "ES-Base_Style"
 

sfdx force:package:version:create -p $package -a $version_name -n $version_number -v $target_dev_hub_username -x -w 10
 

echo "The package is now versioned."