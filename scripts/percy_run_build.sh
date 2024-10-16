#!/bin/sh

# https://www.browserstack.com/docs/app-percy/sample-build/xcuitest

# run Percy build

# Usage: Run this script with the Percy user as the first argument
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

if [ -z "$4" ]; then
  echo "Please provide the PERCY_TOKEN as the fourth argument"
  exit 1
fi

PERCY_USER=$1
PERCY_BUILD_URL=$2
PERCY_TEST_SUITE_URL=$3
PERCY_TOKEN=$4   
PERCY_BRANCH=$5
if [ -z "$5" ]; then
  PERCY_BRANCH=""
fi
PERCY_COMMIT=$6
if [ -z "$6" ]; then
  PERCY_COMMIT=""
fi
PERCY_PULL_REQUEST=$7

JSON_FMT='{ 
  "devices": ["iPhone 15 Pro-17"], 
  "debugscreenshots": "true", 
  "appPercy": { "env": {"PERCY_BRANCH": "%s", "PERCY_COMMIT": "%s" }, "PERCY_TOKEN": "%s"}, 
  "app": "%s", "testSuite": "%s"}'
PAYLOAD=$(printf "$JSON_FMT" "$PERCY_BRANCH" "$PERCY_COMMIT" "$PERCY_TOKEN" "$PERCY_BUILD_URL" "$PERCY_TEST_SUITE_URL")
echo $PAYLOAD

curl -u $PERCY_USER \
-X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
-d "$PAYLOAD" \
-H "Content-Type: application/json"