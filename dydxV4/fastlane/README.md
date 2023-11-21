fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios update_bundle_identifier

```sh
[bundle exec] fastlane ios update_bundle_identifier
```

Update PRODUCT_BUNDLE_IDENTIFIER in Xcode project with the app_identifier from the Appfile

### ios dydx_increment_build_number

```sh
[bundle exec] fastlane ios dydx_increment_build_number
```

Increments the build number based on last build submitted to testflight

### ios update_marketing_version

```sh
[bundle exec] fastlane ios update_marketing_version
```

Update the marketing version in the Xcode project

### ios dydx_update_url_schemes

```sh
[bundle exec] fastlane ios dydx_update_url_schemes
```



### ios generate_app_icons

```sh
[bundle exec] fastlane ios generate_app_icons
```

Generate app icons

### ios enable_associated_domains

```sh
[bundle exec] fastlane ios enable_associated_domains
```



### ios create_build_and_submit_for_review

```sh
[bundle exec] fastlane ios create_build_and_submit_for_review
```

Submit a new build for review

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
