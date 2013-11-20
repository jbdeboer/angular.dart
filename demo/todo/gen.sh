#!/bin/sh

set -evx

#dart2js main.dart
sed -e 's/^\s*\([\$A-Za-z0-9_]*\): function(/\1: function \1(/' out.js >out_ann.js
wtf-instrument --track-heap out_ann.js main.dart.js


