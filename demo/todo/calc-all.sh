#!/bin/sh

for rev in `git rev-list 8619c8e9edf032c7a75e9ecf..HEAD`; do
  echo "REV $rev" >>perflog
  git log HEAD^..HEAD >>perflog
  git checkout $rev
  dart2js main.dart -o main.dart.js

  (google-chrome --user-data-dir=/tmp/aaa --no-first-run http://localhost:3000/debug.html --enable-logging=stderr 2>>perflog & sleep 60; kill %1);
done
