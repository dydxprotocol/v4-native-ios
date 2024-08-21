#!/bin/sh


# Install Command-line tools as dependency for Homebrew
xcode-select --install # Sets the development directory path to /Library/Developer/CommandLineTools

# Install Mas (command-line interface for Mac App Store)
brew install mas

# Search for Xcode showing only the first 5 results
mas search xcode | head -5
# Install Xcode using App ID
mas install 497799835 # The appid for Xcode shown when doing search

sudo xcode-select -r  # Reset the development directory path to put to Xcode /Applications/Xcode.app/Contents/Developer

#sudo xcodebuild -license

# Updaate all Apple software and auto agree to any licenses and restart if necessary
sudo softwareupdate --install --agree-to-license -aR
