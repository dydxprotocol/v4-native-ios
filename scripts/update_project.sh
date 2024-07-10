#!/bin/bash

# 1. Quit Xcode
echo "Quitting Xcode..."
osascript -e 'tell application "Xcode" to quit'

# 2. Check out the specified commit hash
# 1.4.0 c08e065ff4eb5afa28bed666fd87b28d1397fce5 was fine
# c9e87b2382c0f55c2f9272160e3305281c03ed94 is bad (abacus 1.7.47)
# abacus v1.7.38 with ios (#183 a87b92e711af0aead80348b5d921f5c70ec009b1) is good
echo "Checking out commit hash a87b92e711af0aead80348b5d921f5c70ec009b1..."
cd /Users/mike/v4-native-ios/dydx
git checkout develop
git reset --hard

# 3. Replace pod specification using sed
echo "Updating PodFile..."
sed -i '' "s|pod 'Abacus', :podspec => '../podspecs/Abacus.podspec'|pod 'abacus', :path => '~/v4-abacus'|" /Users/mike/v4-native-ios/dydx/PodFile

# 4. Comment out the specified line in dydxGlobalWorkers.swift
echo "Commenting out line in dydxGlobalWorkers.swift..."
sed -i '' "s|Router.shared?.navigate(to: RoutingRequest(path: \"/update\"), animated: true, completion: nil)|// Router.shared?.navigate(to: RoutingRequest(path: \"/update\"), animated: true, completion: nil)|" /Users/mike/v4-native-ios/dydx/dydxPresenters/dydxPresenters/_v4/GlobalWorkers/dydxGlobalWorkers.swift
sed -i '' "s|Router.shared?.navigate(to: RoutingRequest(path: \"/update\"), animated: true, completion: nil)|// Router.shared?.navigate(to: RoutingRequest(path: \"/update\"), animated: true, completion: nil)|" /Users/mike/v4-native-ios/dydx/dydxPresenters/dydxPresenters/_v4/GlobalWorkers/Workers/dydxUpdateWorker.swift

# 4.5. Comment out the assertionFailure line in TrackingViewController+Ext.swift
echo "Commenting out assertionFailure line in TrackingViewController+Ext.swift..."
sed -i '' 's|assertionFailure("no path for \\(screenClass)")|// assertionFailure("no path for \\(screenClass)")|' /Users/mike/v4-native-ios/dydxV4/dydxV4/_Tracking/TrackingViewController+Ext.swift

# 5. Read the version of Abacus from Podfile.lock
echo "Reading Abacus version from Podfile.lock..."
ABACUS_VERSION=$(awk '/- Abacus \(/ && $0 ~ /[0-9]+\.[0-9]+\.[0-9]+/ {gsub(/[()]/, "", $3); print $3}' /Users/mike/v4-native-ios/dydx/Podfile.lock)
echo "Found Abacus version: $ABACUS_VERSION"

# 6. Check out the specific commit tag in the v4-abacus directory
# abacus f432c164a56dff7a4d6c0fbb109809caa492bf30 #400 is fine with iOS a87b92e711af0aead80348b5d921f5c70ec009b1 #183
# abacus 04daa49de5de28b059bb07295e6c3e9d65125f69 #429 is worse with iOS a87b92e711af0aead80348b5d921f5c70ec009b1 #183
# abacus 28ac6907216bd9f25c6f7ac2faeac409613ba769 #398 is locking up with iOS a87b92e711af0aead80348b5d921f5c70ec009b1 #183
echo "Checking out tag v$ABACUS_VERSION in v4-abacus..."
cd /Users/mike/v4-abacus
git checkout tags/v$ABACUS_VERSION

# 7. Return to the dydx directory
echo "Returning to dydx directory..."
cd /Users/mike/v4-native-ios/dydx

# 8. Delete the Derived Data folder
echo "Deleting Derived Data..."
sudo rm -rf /Users/mike/Library/Developer/Xcode/DerivedData

# 9. Delete Pods folder
echo "Deleting Pods folder..."
sudo rm -rf /Users/mike/v4-native-ios/dydx/Pods

# 10. Run pod install
echo "Running pod install..."
pod install

11. Open Xcode
echo "Opening Xcode..."
open /Users/mike/v4-native-ios/dydx/dydx.xcworkspace

# 12. Build the project (optional)
# echo "Building the project..."
# xcodebuild -workspace dydx.xcworkspace -scheme dydx -configuration Debug

echo "Script execution completed."
