#!/bin/sh



(google-chrome --user-data-dir=/tmp/aaa --no-first-run http://localhost:3000/debug.html --enable-logging=stderr & sleep 60; kill %1)
