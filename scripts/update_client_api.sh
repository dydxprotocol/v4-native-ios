#!/bin/bash

# Checking if the directory exists
if [ -d "../../v4-clients/v4-client-js" ]; then
    cd ../../v4-clients/v4-client-js
else
    # If the directory doesn't exist, perform git clone and navigate to the cloned directory
    cd ../..
    git clone git@github.com:dydxprotocol/v4-clients.git
    cd v4-clients/v4-client-js

    # If cloning fails, exit the script
    if [ $? -ne 0 ]; then
        echo "Failed to clone the git@github.com:dydxprotocol/v4-clients.git repository. Please check your network connection and repository access."
        exit 1
    fi
fi

# Running npm commands
npm install
npm run build
npm run webpack

# Copying the file to the specified location
cp __native__/__ios__/v4-native-client.js ../../v4-native-ios/dydx/dydxPresenters/dydxPresenters/_Features/v4-native-client.js

# Navigating to the final directory
cd ../../v4-native-ios/scripts
