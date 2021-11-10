#!/usr/bin/env bash

find . -regex ".*\.applescript$" -not -path "./Libraries/*" -exec ./compile.sh {} \;