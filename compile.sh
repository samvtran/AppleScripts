#!/usr/bin/env bash

basename="$(basename -s .applescript "$1")"
dir="$(dirname "$1")"
basedir="$(basename "$dir")"
mkdir -p "dist/$basedir"
osacompile -o "dist/$basedir/$basename.scpt" "$1"
