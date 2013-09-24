#!/bin/sh

# OS-specific Dartium path defaults
case $( uname -s ) in
  Darwin)
    CHROME_CANARY_BIN=${CHROME_CANARY_BIN:-"/Applications/dart/chromium/Chromium.app/Contents/MacOS/Chromium"};;
esac
if [ ! -x "$CHROME_CANARY_BIN" ]; then
  echo "Unable to determine path to Dartium browser. To correct:"
  echo "export CHROME_CANARY_BIN=path/to/dartium"
  exit 1;
fi
export CHROME_CANARY_BIN
export DART_FLAGS="--enable-type-checks --enable-asserts"

# Check for node
if [ -z "$(which node)" ]; then
  echo "node.js does not appear to be on the path."
  echo "You can obtain it from http://nodejs.org"
  exit 1;
fi

# Run npm install so we are up-to-date
npm install karma karma-dart;

echo "Dart version: $(dart --version)"

./analyze.sh && node "node_modules/karma/bin/karma" start karma.conf \
  --reporters=junit,dots --port=8765 --runner-port=8766 \
  --browsers=ChromeCanary,Chrome --single-run --no-colors --no-color

