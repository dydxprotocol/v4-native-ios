#!/bin/sh

# https://www.browserstack.com/docs/app-percy/sample-build/xcuitest

# upload UI Test Runner to percy

# Usage: Run this script with the Percy user as the first argument
# e.g. ./percy_upload_test_runner.sh ruihuang_ry52wv:HXRCy79y5SDuDvvQw6Qw


unset PERCY_TEST_SUITE_URL

if [ -z "$1" ]; then
  echo "Please provide the Percy user as the first argument"
  exit 1
fi

PERCY_USER=$1
TEST_BUNDLE_PATH=$2

if [ $TEST_BUNDLE_PATH != "/tmp/dydxV4UITests.zip" ]; then
    cp $TEST_BUNDLE_PATH /tmp/dydxV4UITests.zip
fi

response=`curl -u $PERCY_USER \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/test-suite"  \
  -F "file=@/tmp/dydxV4UITests.zip"`

echo $response

# read response as JSON and extract the "test_suite_url" field
test_suite_url=`echo $response | jq -r .test_suite_url`
echo "Test Suite URL: $test_suite_url"

# export the test suite URL as an environment variable
export PERCY_TEST_SUITE_URL=$test_suite_url
