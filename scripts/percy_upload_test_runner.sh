#!/bin/sh

# https://www.browserstack.com/docs/app-percy/sample-build/xcuitest

# upload UI Test Runner to percy

# run this script with the Percy user as the first argument
# e.g. ./percy_upload_test_runner.sh ruihuang_ry52wv:HXRCy79y5SDuDvvQw6Qw

unset PERCY_TEST_SUITE_URL

if [ -z "$1" ]; then
  echo "Please provide the Percy user as the first argument"
  exit 1
fi

PERCY_USER=$1

# get the DerivedData folder
derived_data_path=$(xcodebuild -workspace "dydx/dydx.xcworkspace"  -scheme "dydxV4" -showBuildSettings | grep OBJROOT | cut -d "=" -f 2 - | sed 's/^ *//')

# remove the last part of the path
derived_data_path=$(dirname $derived_data_path)

app_path="$derived_data_path/Products/Debug-iphonesimulator/dydxV4UITests-Runner.app"

if [ ! -d "$app_path" ]; then
  echo "App path not found: $app_path"
  exit 1
fi

cp -r "$app_path" /tmp/dydxV4UITests-Runner.app
zip -r /tmp/dydxV4UITests.zip /tmp/dydxV4UITests-Runner.app

response=`curl -u $PERCY_USER \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/test-suite"  \
  -F "file=@/tmp/dydxV4UITests.zip"`

# read response as JSON and extract the "test_suite_url" field
test_suite_url=`echo $response | jq -r .test_suite_url`
echo "Test Suite URL: $test_suite_url"

# export the test suite URL as an environment variable
export PERCY_TEST_SUITE_URL=$test_suite_url