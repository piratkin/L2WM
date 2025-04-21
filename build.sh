#!/bin/zsh

xcodebuild \
-scheme L2WM \
-configuration Release \
-project L2WM.xcodeproj \
-allowProvisioningUpdates \
-derivedDataPath ./BuildOutput \
build
