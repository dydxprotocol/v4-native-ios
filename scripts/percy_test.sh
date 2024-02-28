#!/bin/sh


. ./scripts/percy_upload_ipa.sh ruihuang_ry52wv:HXRCy79y5SDuDvvQw6Qw /tmp/dydxV4.ipa

echo "PERCY_BUILD_URL: $PERCY_BUILD_URL"

. ./scripts/percy_upload_test_runner.sh ruihuang_ry52wv:HXRCy79y5SDuDvvQw6Qw

echo "PERCY_TEST_SUITE_URL: $PERCY_TEST_SUITE_URL"

if [ -z "$PERCY_BUILD_URL" ]; then
  echo "PERCY_BUILD_URL not found"
  exit 1
fi

if [ -z "$PERCY_TEST_SUITE_URL" ]; then
  echo "PERCY_TEST_SUITE_URL not found"
  exit 1
fi

PERCY_TOKEN=app_840d58d0148ceacff970b7f143832b469d650bdaf222d18c4db0b9324dd5b40c
PERCY_BRANCH=features/ui_tests

echo $PERCY_BUILD_URL
echo $PERCY_TEST_SUITE_URL
echo $PERCY_TOKEN

PERCY_COMMIT=`git log --pretty=format:‘%H’ -n 1`
# Remove the leading and trailing single quotes
PERCY_COMMIT="${PERCY_COMMIT:1:${#PERCY_COMMIT}-2}"
echo "PERCY_COMMIT: $PERCY_COMMIT"

./scripts/percy_run_build.sh ruihuang_ry52wv:HXRCy79y5SDuDvvQw6Qw "$PERCY_BUILD_URL" "$PERCY_TEST_SUITE_URL" "$PERCY_TOKEN" "$PERCY_BRANCH" "$PERCY_COMMIT"
