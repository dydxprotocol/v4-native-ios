#!/bin/sh

PATH=${PATH}:/opt/local/bin:/opt/homebrew/bin

SCRIPT_DIR=$(dirname "$0")
REPO_DIR="$SCRIPT_DIR/.."
INFO_PLIST="$REPO_DIR/dydxV4/dydxV4/Info.plist"

if [ ! -f "$INFO_PLIST" ]; then
  echo "Info.plist file $INFO_PLIST does not exist"
  exit 1
fi

if ! command -v jq &> /dev/null
then
  echo "Installing jq"
  brew install jq
fi

if ! command -v curl &> /dev/null
then
  echo "Installing curl"
  brew install curl
fi

SECRETS_DIR="$SCRIPT_DIR/secrets"
if [ ! -d "$SECRETS_DIR" ]; then
  echo "Secrets directory $SECRETS_DIR does not exist"
  exit 1
fi

CREDENTIALS_FILE="$SECRETS_DIR/credentials.json"
if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "Credentials file $CREDENTIALS_FILE does not exist"
  exit 1
fi

# read the credentials.json and find the webAppUrl field
WEB_APP_URL=$(jq -r '.webAppUrl.value' "$CREDENTIALS_FILE")
if [ -z "$WEB_APP_URL" ]; then
  echo "Could not find webAppUrl in $CREDENTIALS_FILE"
  exit 1
fi

echo "Fetching env.json from $WEB_APP_URL"

ENV_JSON=$(curl -X GET $WEB_APP_URL/configs/env.json)
if [ -z "$ENV_JSON" ]; then
  echo "Could not fetch env.json from $WEB_APP_URL"
  exit 1
fi

SCHEME=$(echo $ENV_JSON | jq -r '.apps.ios.scheme')
if [ -z "$SCHEME" ]; then
  echo "Could not find scheme in env.json"
  exit 1
fi

# update the Info.plist file
echo "Updating $INFO_PLIST with scheme $SCHEME"
/usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 $SCHEME" "$INFO_PLIST"
