#!/bin/bash

function replace_line {
  local file="$1"
  local search="$2"
  local replace="$3"

  if [ ! -f "$file" ]; then
    echo "Error: the file $file does not exist."
    return 1
  fi

  local temp_file=$(mktemp)
  while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == *"$search"*"="* ]]; then
      line="$replace"
    fi
    echo "$line" >> "$temp_file"
  done < "$file"

  mv "$temp_file" "$file"
}

killall Xcode

# If a command fails, exit the script
set -e

scriptDir=`pwd`

cd /tmp
rm -rf abacus
gh repo clone git@github.com:dydxprotocol/v4-abacus.git abacus
version=`cat abacus/v4_abacus.podspec | grep spec.version | grep -o '[0-9]*\.[0-9]*\.[0-9]*'`
echo "=================================="
echo "Bumping to $version.... hang on..."



echo "=================================="
echo "Checking git tag v$version"

cd abacus
exist=`git tag | grep "v$version" || true`
if [ ! -z "$exist" ]; then
  echo "v$version exists"
else
  echo "Creating git tag v$version"
  username=$(git config user.name)
  git tag -a "v$version" -m "v$version created by $username"
  git push --tags origin main
fi


cd $scriptDir/..

echo "=================================="
echo "Updating iOS repo at $`pwd`"


echo "Updating Abacus.podspec..."
replace_line podspecs/Abacus.podspec "spec.version" "spec.version = '$version'"

echo "Pod update..."
cd dydx
pod update

echo "Xcode build... (ignoring error)"
xcodebuild -workspace dydx.xcworkspace -scheme dydxV4 build -destination generic/platform=iOS || true

pod install

echo "Xcode build... (this time it should build)"
xcodebuild -workspace dydx.xcworkspace -scheme dydxV4 build -destination generic/platform=iOS || true

pod install

echo "=================================="
echo "Done.. Please create a PR with the change."

open /Applications/Xcode.app 

