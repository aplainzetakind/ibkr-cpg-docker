#!/usr/bin/env bash

pushd /pw > /dev/null || exit
PLAYWRIGHT_BROWSERS_PATH=/ms-playwright node login.js
popd > /dev/null || exit
