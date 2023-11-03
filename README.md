# Background

This is the native iOS app for dYdX v4.

# Quick Setup

> cd scripts

> ./bootstrap.sh

This will set up Xcode project along with all dependencies.

From Xcode, select the "dydxV4" scheme to build.

# Repo Dependencies

This project requires v4-localization

https://github.com/dydxprotocol/v4-localization

This project requires v4-web

https://github.com/dydxprotocol/v4-web

Other dependencies are specified by the Cocoapods and Swift Package Manager configurations in the project.

# API Keys & Secrets
Unzip the `secrets.zip` from the `iOS Secrets` vault in the dYdX 1Password account. Ask a team member for access.
Add the `secrets/` folder to the native-ios-v4/scripts folder.

> `mv {REPLACE_WITH_PATH_TO_UNZIPPED}/secrets {REPLACE_WITH_REPO}/scripts`


# Tools Setup

Always use latest Xcode.
https://apps.apple.com/us/app/xcode/id497799835?mt=12

Uploading with Xcode organizer often fails. Use Transporter for uploading
https://apps.apple.com/us/app/transporter/id1450874784?mt=12

# Update Javascript

Javascript code is generated in v4-client. To update

Get the desired commit from v4-client
Copy from {v4-client}/__native__/__ios__/v4-native-client.js
to {native-ios-v4}/dydx/dydxPresenters/_Feature/

To generate v4-native-client.js from the v4-client repo, run

> npm run build

> npm run webpack

# Update Fonts

By default, the repo uses the open source font Satoshi aside from monospaced texts for which the repo uses Satoshi. If you would like to use your own, custom fonts for bolded texts, standard texts, or number texts, please follow these instructions.

## Add Font Files

Current as of Oct 12, 2023. See [Apple's instructions](https://developer.apple.com/documentation/uikit/text_display_and_fonts/adding_a_custom_font_to_your_app) for more updated instructions for steps 1 & 2

### 1. Add the Font File to Your Xcode Project
To add a font file to your Xcode project, select File > Add Files to “Your Project Name” from the menu bar, or drag the file from Finder and drop it into your Xcode project. You can add True Type Font (.ttf) and Open Type Font (.otf) files. Also, make sure the font file is a target member of your app; otherwise, the font file will not be distributed as part of your app.

<img src="https://docs-assets.developer.apple.com/published/35bc80c902/d373ed5c-a36b-46fe-9bd8-bf49700072be.png">

On the left, a screenshot of the Project Navigator showing the custom font files added to the CustomFont project. On the right, a screenshot of the File Inspector showing that the selected font file is a target member of the app CustomFont.

### 2. Register Your Font File with iOS
After adding the font file to your project, you need to let iOS know about the font. To do this, add the key "Fonts provided by application" to Info.plist (the raw key name is UIAppFonts). Xcode creates an array value for the key; add the name of the font file as an item of the array. Be sure to include the file extension as part of the name.

Screenshot of Xcode showing the contents of the Info.plist file. The "Fonts provided by application" key contains the two file fonts that were added to the project.

<img src="https://docs-assets.developer.apple.com/published/1b7e45d9c2/f9329213-4abb-413e-a339-4b91ee4bf554.png">

Each font file you add to your project must be listed in this array; otherwise, the font will not be available to your app.

### 3. Configure Styles to Use Fonts
Your project should have one or more theme files. 

<img src="https://github.com/dydxprotocol/v4-chain/assets/3445394/31f1fbcf-229e-498b-aec2-7e8750956679">

For each theme file, you must replace the values at paths `themeFont.type.bold`, `themeFont.type.text`, or `themeFont.type.number` for each custom font you want to use. 
