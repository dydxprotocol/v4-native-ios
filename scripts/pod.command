#! /bin/bash

# Add an env variable to your shell (~/.zshrc, ~/.bashrc, etc) to customize
# export DYDX_IOS_ROOT="$HOME/path/to/ios"

# If not set, use "~/native-ios"
ios_root_dir=${DYDX_IOS_ROOT:-"$HOME/native-ios"}
echo "Using ios root dir: $ios_root_dir"

cd "$ios_root_dir/dydx" || exit 1

rm -rf "Pods"

cd ".."
for dir in *; do
    if [ -d ${dir} ]; then
        echo "$dir"
        cd "$dir"
        pwd
        pod deintegrate
        cd ..
    fi
done

cd "dydx"
pwd
pod repo update
pod update

