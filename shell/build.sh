#!/bin/bash
#=======================================================================
#
#          FILE:  build.sh
#
#         USAGE:  ./build.sh <platforms>
#
#       OPTIONS:  ./build.sh <platforms>
#  REQUIREMENTS:  <platforms> is a comma-seperated list of platforms
#                 like: "osx64,win32"
#         NOTES:  ---
#        AUTHOR: Brannon Dorsey, <brannon@brannondorsey.com>
#       COMPANY:  ---
#       CREATED: 05.01.2015
#      REVISION: 0.0.1
#=======================================================================

OS=$(uname)
SCRIPT_NAME=$(basename $0)
DIR_NAME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BUILD_DIR="$DIR_NAME/../build"
TMP_DIR="$DIR_NAME/../tmp"
PLATFORMS="$1"
BUNDLE_NAME="Probe Kit"
NODE_VERSION="0.11.6"

#Must be root
if [[ $EUID -ne 0 ]] || [[ $# -ne "1" ]]; then
    echo "[$SCRIPT_NAME] This script must be run as root:"
    echo "    sudo ./build <platforms>"
    exit 1
fi

# remove old build dir
if [[ -d $BUILD_DIR ]]; then
    echo "[$SCRIPT_NAME] removing $BUILD_DIR"
    rm -rf $BUILD_DIR 
fi

# create tmp folder
mkdir -p $TMP_DIR

echo "[$SCRIPT_NAME] copying files to $TMP_DIR"
cp -rp "$DIR_NAME/../shell" "$TMP_DIR/shell"
cp -rp "$DIR_NAME/../public" "$TMP_DIR/public"
cp -rp "$DIR_NAME/../node" "$TMP_DIR/node"
cp -rp "$DIR_NAME/../package.json" "$TMP_DIR/package.json"
mkdir "$TMP_DIR/data"

for FILE in $(ls $DIR_NAME/../data); do
    echo "$DIR_NAME/../data/$FILE"
    echo "$TMP_DIR/data/"
    echo ""
    if [ ! "$FILE" == "wigle_data" ]; then
        echo "IN HERE: $FILE"
        cp -rp "$DIR_NAME/../data/$FILE" "$TMP_DIR/data/"
    fi
done

# rebuild C++ source node_modules for NW.js <- needed only for NW v0.12.0 and above
# echo "[$SCRIPT_NAME] rebuilding \"node_pcap\" module for NW.js"
# cd "$TMP_DIR/node/node_modules/pcap/"
# "$TMP_DIR/node/node_modules/nw-gyp/bin/nw-gyp.js" rebuild --target=$NODE_VERSION
# echo "[$SCRIPT_NAME] rebuilding \"node-socketwatcher\" module for NW.js"
# cd "node_modules/socketwatcher"
# "$TMP_DIR/node/node_modules/nw-gyp/bin/nw-gyp.js" rebuild --target=$NODE_VERSION
# cd "$DIR_NAME"

# remove unneeded items
if [[ -d "$TMP_DIR/data/ChmodBPF" ]]; then
    echo "[$SCRIPT_NAME] removing $TMP_DIR/data/ChmodBPF"
    rm -rf "$TMP_DIR/data/ChmodBPF"
fi

if [[ -d "$TMP_DIR/data/wigle_data" ]]; then
    echo "[$SCRIPT_NAME] removing $TMP_DIR/data/wigle_data"
    rm -rf "$TMP_DIR/data/wigle_data"
fi

if which nwbuild &>/dev/null ; then

    echo "[$SCRIPT_NAME] building $BUNDLE_NAME"
    nwbuild -v "$NODE_VERSION" -p "$PLATFORMS" -o "$BUILD_DIR" "$TMP_DIR"

    if [[ ! $? ]]; then
        echo "[$SCRIPT_NAME] Error building with nwbuild"
        exit 1
    fi

else
    echo "[$SCRIPT_NAME] Error: nwbuild is not installed. Install nwbuild with:"
    echo "  sudo npm install -g node-webkit-builder"
    exit 1
fi

if [[ "osx64" =~ "$PLATFORMS" ]]; then
    
    echo "[$SCRIPT_NAME] replacing app icon"
    cp "$DIR_NAME/../media/icon_butterfly.icns" "$BUILD_DIR/$BUNDLE_NAME/osx64/$BUNDLE_NAME.app/Contents/Resources/nw.icns"

    cp "$DIR_NAME/build_install.sh" "$BUILD_DIR/$BUNDLE_NAME/osx64/install.sh"

    chmod +x "$BUILD_DIR/$BUNDLE_NAME/osx64/install.sh"
fi

# remove tmp folder
rm -rf $TMP_DIR
