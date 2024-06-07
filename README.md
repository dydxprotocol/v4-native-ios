<div align="center">
  <img src='https://github.com/dydxprotocol/v4-native-ios/blob/develop/dydxV4/dydxV4/Assets.xcassets/AppIcon.appiconset/AppIcon-180x180.png' alt='icon' />
</div>
<h1 align="center">v4-native-ios</h1>

<div align="center">
  <a href='https://github.com/dydxprotocol/v4-native-ios/blob/main/LICENSE'>
    <img src='https://img.shields.io/badge/License-AGPL_v3-blue.svg' alt='License' />
  </a>
</div>

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
Add the `secrets/` folder to the v4-native-ios/scripts folder.

> `mv {REPLACE_WITH_PATH_TO_UNZIPPED}/secrets {REPLACE_WITH_REPO}/scripts`


# Tools Setup

Always use latest Xcode.
https://apps.apple.com/us/app/xcode/id497799835?mt=12

Uploading with Xcode organizer often fails. Use Transporter for uploading
https://apps.apple.com/us/app/transporter/id1450874784?mt=12

# Update Javascript

Javascript code is generated from v4-client. Note, this shell script must be executed from the **scripts/** directory. It will attemp to clone `v4-clients` if `v4-clients` does not exist next to where you have checked out `v4-native-ios`

> ./update_client_apis.sh

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

_______
*By using, recording, referencing, or downloading (i.e., any “action”) any information contained on this page or in any dYdX Trading Inc. ("dYdX") database or documentation, you hereby and thereby agree to the [v4 Terms of Use](https://dydx.exchange/v4-terms) and [Privacy Policy](https://dydx.exchange/privacy) governing such information, and you agree that such action establishes a binding agreement between you and dYdX.*

*This documentation provides information on how to use dYdX v4 software (”dYdX Chain”). dYdX does not deploy or run v4 software for public use, or operate or control any dYdX Chain infrastructure. dYdX is not responsible for any actions taken by other third parties who use v4 software. dYdX services and products are not available to persons or entities who reside in, are located in, are incorporated in, or have registered offices in the United States or Canada, or Restricted Persons (as defined in the dYdX [Terms of Use](https://dydx.exchange/terms)). The content provided herein does not constitute, and should not be considered, or relied upon as, financial advice, legal advice, tax advice, investment advice or advice of any other nature, and you agree that you are responsible to conduct independent research, perform due diligence and engage a professional advisor prior to taking any financial, tax, legal or investment action related to the foregoing content. The information contained herein, and any use of v4 software, are subject to the [v4 Terms of Use](https://dydx.exchange/v4-terms).*
