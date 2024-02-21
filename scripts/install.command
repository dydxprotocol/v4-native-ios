#! /bin/bash

# Add an env variable to your shell (~/.zshrc, ~/.bashrc, etc) to customize
# export DYDX_IOS_ROOT="$HOME/path/to/ios"

# If not set, use "~/native-ios"
ios_root_dir=${DYDX_IOS_ROOT:-"$HOME/v4-native-ios"}
echo "Using ios root dir: $ios_root_dir"

cd "$ios_root_dir/dydx" || exit 1

pwd
rm -rf "Pods"
pod repo update || exit 1
pod install

