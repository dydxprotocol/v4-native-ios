#!/bin/sh

PATH=${PATH}:/opt/local/bin:/opt/homebrew/bin

SCRIPT_DIR=$(dirname "$0")
REPO_DIR="$SCRIPT_DIR/.."
INFO_PLIST="$REPO_DIR/dydxV4/dydxV4/Info.plist"

echo "Script directory: $SCRIPT_DIR"
echo "Repository directory: $REPO_DIR"
echo "Info.plist path: $INFO_PLIST"

if [ ! -f "$INFO_PLIST" ]; then
  echo "Info.plist file $INFO_PLIST does not exist"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "Installing jq"
  brew install jq
fi

if ! command -v curl &> /dev/null; then
  echo "Installing curl"
  brew install curl
fi

SECRETS_DIR="$SCRIPT_DIR/secrets"
echo "Secrets directory: $SECRETS_DIR"
if [ ! -d "$SECRETS_DIR" ]; then
  echo "Secrets directory $SECRETS_DIR does not exist"
  exit 1
fi

CREDENTIALS_FILE="$SECRETS_DIR/credentials.json"
echo "Credentials file path: $CREDENTIALS_FILE"
if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "Credentials file $CREDENTIALS_FILE does not exist"
  exit 1
fi

echo "Reading webAppUrl from credentials.json"
WEB_APP_URL=$(jq -r '.webAppUrl.value' "$CREDENTIALS_FILE")
echo "Web App URL before cleaning: $WEB_APP_URL"
if [ -z "$WEB_APP_URL" ]; then
  echo "Could not find webAppUrl in $CREDENTIALS_FILE"
  exit 1
fi

# Remove trailing slash from WEB_APP_URL if it exists
WEB_APP_URL=${WEB_APP_URL%/}
echo "Web App URL after cleaning: $WEB_APP_URL"

echo "Fetching env.json from $WEB_APP_URL"
ENV_JSON=$(curl -X GET "$WEB_APP_URL/configs/env.json")
if [ $? -ne 0 ]; then
  echo "Failed to fetch env.json from $WEB_APP_URL"
  exit 1
fi

if [ -z "$ENV_JSON" ]; then
  echo "env.json is empty"
  exit 1
fi

# Validate JSON format
echo "$ENV_JSON" | jq . > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Fetched env.json is not valid JSON:"
  echo "$ENV_JSON"
  exit 1
fi

echo "Fetched env.json:"
echo "$ENV_JSON"

echo "Extracting scheme from env.json"
SCHEME=$(echo "$ENV_JSON" | jq -r '.apps.ios.scheme')
echo "Scheme: $SCHEME"
if [ -z "$SCHEME" ]; then
  echo "Could not find scheme in env.json"
  exit 1
fi

echo "Updating $INFO_PLIST with scheme $SCHEME"
/usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 $SCHEME" "$INFO_PLIST"
if [ $? -eq 0 ]; then
  echo "Successfully updated $INFO_PLIST with scheme $SCHEME"
else
  echo "Failed to update $INFO_PLIST"
  exit 1
fi
