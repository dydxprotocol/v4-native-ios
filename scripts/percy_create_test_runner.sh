#!/bin/sh

# Create UI Test Runner for Percy.  The output is a zip file that contains the UI Test Runner.
# Output file: /tmp/dydxV4UITests.zip

xcodebuild -workspace "dydx/dydx.xcworkspace" \
  -scheme "dydxV4UITests" -derivedDataPath /tmp/dydxV4UITests \
  -configuration Debug -sdk iphoneos build-for-testing

derived_data_path=/tmp/dydxV4UITests/Build

# # get the DerivedData folder
# derived_data_path=$(xcodebuild -workspace "dydx/dydx.xcworkspace"  -scheme "dydxV4" -showBuildSettings | grep OBJROOT | cut -d "=" -f 2 - | sed 's/^ *//')

# # remove the last part of the path
# derived_data_path=$(dirname $derived_data_path)

app_path="$derived_data_path/Products/Debug-iphoneos/dydxV4UITests-Runner.app"

if [ ! -d "$app_path" ]; then
  echo "App path not found: $app_path"
  exit 1
fi

if [ -f /tmp/dydxV4UITests.zip ]; then
  rm /tmp/dydxV4UITests.zip
fi

cwd=$(pwd)
cp -r "$app_path" /tmp/dydxV4UITests-Runner.app
cd /tmp
zip -r dydxV4UITests.zip dydxV4UITests-Runner.app/
cd $cwd