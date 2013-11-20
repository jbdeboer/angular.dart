#!/bin/sh

set -evx

#dart2js main.dart
sed -e 's/^\s*\([0-9]\+\)\s*\([\$A-Za-z0-9_]*\): function(/ 4\t\2: function \2_\1(/' out_numbered.js >out_na.js

sed -e 's/^\s*[0-9]\+\t//' out_na.js >out_ann.js
wtf-instrument --track-heap out_ann.js main.dart.js


