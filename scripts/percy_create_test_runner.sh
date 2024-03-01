#!/bin/sh

# Create UI Test Runner for Percy via xcodebuild.  The output is a zip file that contains the UI Test Runner.
# Output file: <input folder>/dydxV4UITests.zip
#
# Note this script is intended to be run from a development machine, not from a CI/CD environment.
# For CI/CD, you will need to run the CI/CD step to build the project and extract the UI Test Runner.

if [ -z "$1" ]; then
  echo "Please provide the output folder path as the first argument"
  exit 1
fi

TMP_FOLDER=$1

xcodebuild -workspace "dydx/dydx.xcworkspace" \
  -scheme "dydxV4UITests" -derivedDataPath $TMP_FOLDER/dydxV4UITests \
  -configuration Debug -sdk iphoneos build-for-testing

derived_data_path=$TMP_FOLDER/dydxV4UITests/Build

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
  rm $TMP_FOLDER/dydxV4UITests.zip
fi

cwd=$(pwd)
cp -r "$app_path" $TMP_FOLDER/dydxV4UITests-Runner.app
cd $TMP_FOLDER
zip -r dydxV4UITests.zip dydxV4UITests-Runner.app/
cd $cwd