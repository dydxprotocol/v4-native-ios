# Forced Update Guide

This document outlines how to force app users to update to a particular version.

## 1. When to force an update

When Blockchain contract changes, FE app may need to be updated to be compatible. While web apps can be updated in sync with the contracts, native app users may not always update to the latest version.
</br>
</br>
Forced update is a mechanism to make sure the native app is compatible with the contracts, and Indexer endpoints.

## 2. Forced update strategy

Remote configuration is used to inform the app the minimum build number required.

### 2.1 Build number

Each app deployment has a build number, which is automatically incremented at build time. When the remote configuration contains a higher build number than the running app, app shows an UI to force the user to update the app.

### 2.2 Update URL

An URL is provided in the remote configuration. This URL should lead to the App Store to either 

#### 2.2.1

Update the existing app

#### 2.2.2

Download a different app. This is a mechanism to release completely new app and prompt users of older app to migrate to the new app.

## 3. Remote Configuration

The remote configuration resides inside the Environment payload in the web app deployment, which should reside in **\public\configs\env.json**

Having the endpoint to the deployed web app is a necessary step to configure the native app deployment.

Different environments may have different app requirements. This enables the native apps to be deployed and tested with testnets before production network is deployed.

## 4. Sample Payload

In each environment, there is an optional **apps** payload.

```
"apps": {
   "ios": {
      "minimalVersion": "1.0",
      "build":40000,
      "url": "https://apps.apple.com/app/dydx/id1234567890"
   }
 }
 ```


**ios** and **android** is used to identify the requirments for iOS or Android apps.

**minimalVersion** used by the app to display required version. It is used for displaying only. 

**build** is the minimum build number to be compatible with the environment. 

**url** is the URL to the app on the App Store or Google Play Store.

