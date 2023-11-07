#!/bin/sh

SCRIPT_DIR=$(dirname "$0")
REPO_DIR="$SCRIPT_DIR/.."
INFO_PLIST="$REPO_DIR/dydxV4/dydxV4/Info.plist"

if [ ! -f "$INFO_PLIST" ]; then
  echo "Info.plist file $INFO_PLIST does not exist"
  exit 1
fi

/usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 {APP_SCHEME}" "$INFO_PLIST"
