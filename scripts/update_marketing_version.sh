#!/bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 MarketingVersion" >&2
  exit 1
fi

echo "Updating marketing version in dydx.xcodeproj to $1"
xcrun agvtool new-marketing-version $1
