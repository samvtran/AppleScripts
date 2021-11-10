# AppleScripting

Welcome to my messy collection of AppleScript utilities! I hope you find something useful.

# Installation

AppleScript files in this repo use uncompiled scripts. To compile all libraries and scripts, run:

```shell
./compile-libs.sh
mkdir -p ~/Library/Script\ Libraries
ln -s $(pwd)/dist/Libraries/*.scpt ~/Library/Script\ Libraries
./compile-scripts.sh
```

## Script Libraries
Some scripts make use of common utilities spun out into global script libraries. These can be
copied or symlinked from the `dist/Libraries` folder to the `~/Library/Script Libraries` folder as needed.

For example:

```shell
# Compile libs first
./compile-libs.sh

# Then symlink them into place
ln -s $(pwd)/dist/Libraries/*.scpt ~/Library/Script\ Libraries
```

## DEVONthink

### References from Bookends
Syncs Bookends references to a group in a given database. Options can be changed at the top of the script.

Symlink/copy to `~/Library/Application Scripts/com.devon-technologies.think3/Menu` (or elsewhere) for
easy access.

### Set Zettel Data
Given a custom metadata field `zettelkastenid` and Zettelkasten entries prefixed by a 14 digit epoch
time code, this Smart Rule script will copy the time code to the custom metadata field.

Symlink/copy to `~/Library/Application Scripts/com.devon-technologies.think3/Smart Rules` and create
a Smart Rule with:
- _Search in_ set to your Zettelkasten group
- A predicate where the `zettelkastenid` is empty
- An action to _Execute Script_ set to _External_ and pointing to _Set Zettel Data_

## Bookends
Custom formats should go in `~/Library/Application Support/Bookends/Custom Formats`.