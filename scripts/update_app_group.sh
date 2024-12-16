#!/bin/sh

# This script is used to update the app group of the app.

# Check the number of arguments.
if [ $# -ne 1 ]; then
    echo "Usage: $0 <app_group>"
    exit 1
fi

# Read the app group from the command line.
app_group=$1

old_app_group="group.exchange.dydx.v4"

ENTITLEMENTS_FILE="./dydxV4/dydxV4/dydx.entitlements"
if [ ! -f $ENTITLEMENTS_FILE ]; then
    echo "The entitlements file does not exist."
    exit 1
fi

sed -i '' "s/$old_app_group/$app_group/g" $ENTITLEMENTS_FILE

CARTERA_FILE="./dydx/dydxPresenters/dydxPresenters/_v4/GlobalWorkers/Workers/dydxCarteraConfigWorker.swift"
if [ ! -f $CARTERA_FILE ]; then
    echo "The cartera file does not exist."
    exit 1
fi

sed -i '' "s/$old_app_group/$app_group/g" $CARTERA_FILE
