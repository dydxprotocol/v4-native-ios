#!/bin/sh

# https://www.browserstack.com/docs/app-percy/sample-build/xcuitest

# upload builds to percy

cd /tmp

curl -u "ruihuang_ry52wv:HXRCy79y5SDuDvvQw6Qw"  \
    -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/app"  \
    -F "file=@/tmp/dydxV4.ipa"

curl -u "ruihuang_ry52wv:HXRCy79y5SDuDvvQw6Qw"  \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/test-suite"  \
  -F "file=@/tmp/dydxV4UITests.zip"

