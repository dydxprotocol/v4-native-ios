#!/bin/sh

# https://www.browserstack.com/docs/app-percy/sample-build/xcuitest

# upload IPA to percy

# Usage: Run this script with the Percy user id as the first argument and the path to the IPA as the second argument
# e.g. ./percy_upload_ipa.sh ruihuang_ry52wv:HXRCy79y5SDuDvvQw6Qw /path/to/dydxV4.ipa

unset PERCY_BUILD_URL

if [ -z "$1" ]; then
  echo "Please provide the Percy user as the first argument"
  exit 1
fi

if [ -z "$2" ]; then
  echo "Please provide the IPA path as the second argument"
  exit 1
fi

PERCY_USER=$1
IPA_PATH=$2

cp $IPA_PATH /tmp/dydxV4.ipa

response=`curl -u $PERCY_USER  \
    -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/app"  \
    -F "file=@/tmp/dydxV4.ipa"`

# read response as JSON and extract the "app_url" field
app_url=`echo $response | jq -r .app_url`
echo "App URL: $app_url"

# export the app URL as an environment variable
export PERCY_BUILD_URL=$app_url
