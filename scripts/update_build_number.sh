#!/bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 BuildNumber" >&2
  exit 1
fi

echo "Updating build number in dydx.xcodeproj to $1"
xcrun agvtool new-version -all $1 
