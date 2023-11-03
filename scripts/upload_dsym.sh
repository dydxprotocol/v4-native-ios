#!/bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 BuildNumber" >&2
  exit 1
fi

cd ../dydx
fastlane refresh_dsyms build_number:$1
