#!/bin/sh

# https://www.browserstack.com/docs/app-percy/sample-build/xcuitest

# run Percy build

# run this script with the Percy user as the first argument
# e.g. ./percy_run_build.sh ruihuang_ry52wv:HXRCy79y5SDuDvvQw6Qw

if [ -z "$1" ]; then
  echo "Please provide the Percy user as the first argument"
  exit 1
fi

if [ -z "$2" ]; then
  echo "Please provide the PERCY_BUILD_URL as the second argument"
  exit 1
fi

if [ -z "$3" ]; then
  echo "Please provide the PERCY_TEST_SUITE_URL as the third argument"
  exit 1
fi

if [ z "$4" ]; then
  echo "Please provide the PERCY_TOKEN as the fourth argument"
  exit 1
fi

PERCY_USER=$1
PERCY_BUILD_URL=$2
PERCY_TEST_SUITE_URL=$3
PERCY_TOKEN=$4      

curl -u $PERCY_USER \
-X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
-d '{
  "devices": ["iPhone 15 Pro-17"],
 "debugscreenshots": "true",
  "appPercy": { "env": {"PERCY_BRANCH": "features/ui_tests", "PERCY_PULL_REQUEST": "56", "PERCY_COMMIT": "9f53471408cf1639b6c36e26cb6bbb5681658cf3"  }, "PERCY_TOKEN": "$PERCY_TOKEN"},
  "app": "$PERCY_BUILD_URL", "testSuite": "$PERCY_TEST_SUITE_URL"}' \
-H "Content-Type: application/json"