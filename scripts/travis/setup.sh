#!/bin/bash

set -e

case $( uname -s ) in
  Linux)
    DART_SDK_ZIP=dartsdk-linux-x64-release.zip
    DARTIUM_ZIP=dartium-linux-x64-release.zip
    ;;
  Darwin)
    DART_SDK_ZIP=dartsdk-macos-x64-release.zip
    DARTIUM_ZIP=dartium-macos-ia32-release.zip
    ;;
esac

CHANNEL=`echo $JOB | cut -f 2 -d -`
echo Fetch Dart channel: $CHANNEL

echo http://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/latest/sdk/$DART_SDK_ZIP
curl http://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/latest/sdk/$DART_SDK_ZIP > $DART_SDK_ZIP
echo Fetched new dart version $(unzip -p $DART_SDK_ZIP dart-sdk/version)
rm -rf dart-sdk
unzip $DART_SDK_ZIP > /dev/null
rm $DART_SDK_ZIP

if [[ $TESTS != "dart2js" ]]; then
  echo http://storage.googleapis.com/dart-archive/channels/$CHANNEL/raw/latest/dartium/$DARTIUM_ZIP
  curl http://storage.googleapis.com/dart-archive/channels/$CHANNEL/raw/latest/dartium/$DARTIUM_ZIP > $DARTIUM_ZIP
  unzip $DARTIUM_ZIP > /dev/null
  rm -rf dartium
  rm $DARTIUM_ZIP
  mv dartium-* dartium;
fi

echo =============================================================================
. ./scripts/env.sh
$DART --version
$PUB install

echo Increased dart2js\' heap size
#sed -i `which dart2js` -e 's/--heap_growth_rate=512/--heap_growth_rate=512 --old_gen_heap_size='
#sed -i `which dart2js` -e 's/
#echo ============== DART2JS
#cat `which dart2js`
#echo DART2JS ==============
