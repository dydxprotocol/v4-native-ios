#!/bin/sh

ROOT_DIR=$(pwd)/../../

cp pre-commit ../.git/hooks

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Xcode
XCODE=/Applications/Xcode.app
if [ ! -d "$XCODE" ]; then
	./update_xcode.sh
fi

brew install cocoapods
brew install java
brew install SwiftLint
brew install gradle
brew install xcode-kotlin
brew install gh
xcode-kotlin install

sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

cd "$ROOT_DIR"

if [ ! -d "v4-localization" ]; then
	git clone git@github.com:dydxprotocol/v4-localization.git
else
	cd v4-localization
	git pull
	cd ..
fi

open v4-native-ios/dydx/dydx.xcworkspace

#xcodebuild -workspace v4-native-ios/dydx/dydx.xcworkspace -scheme dydxV4 -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 11,OS=14.4' build

#xcodebuild clean archive -archivePath build/dydxV4 -scheme dydxV4 -workspace  v4-native-ios/dydx/dydx.xcworkspace -sdk iphoneos -destination 'generic/platform=iOS' CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
