#!/usr/bin/env bash

find Libraries -regex ".*\.applescript$" -exec ./compile.sh {} \;