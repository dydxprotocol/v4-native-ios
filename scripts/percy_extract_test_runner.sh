#!/bin/sh

# Extract the test runner from the test bunldle .zip file created by CI/CD
# Output file: <input folder>/dydxV4UITests.zip
#
# Usage: Run this script with the path to the test bundle .zip file as the first argument

if [ -z "$1" ]; then
  echo "Please provide the test bundle .zip file path as the first argument"
  exit 1
fi

TEST_BUNDLE_PATH=$1

if [ -z "$2" ]; then
  echo "Please provide the output folder path as the second argument"
  exit 1
fi

TMP_FOLDER=$2

TMP_PATH=$TMP_FOLDER/dydxV4TestBundle.zip

if [ -f $TMP_PATH ]; then
  rm $TMP_PATH
fi

cp $TEST_BUNDLE_PATH $TMP_PATH

pwd=$(pwd)

cd $TMP_FOLDER

if [ -d test_bundle ]; then
  rm -rf test_bundle
fi
unzip $TMP_PATH -d test_bundle
cp -r  test_bundle/Debug-iphoneos/dydxV4UITests-Runner.app $TMP_FOLDER/dydxV4UITests-Runner.app
zip -r dydxV4UITests.zip dydxV4UITests-Runner.app/

cd $pwd

echo $TMP_FOLDER/dydxV4UITests.zip
