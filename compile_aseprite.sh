#!/bin/bash

#is brew installed? if not, install it
command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew Now"; /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; }



# install required  tools 
brew update
brew install ninja
brew install cmake

# crete the default root directory
mkdir $HOME/Aseprite
cd $HOME/Aseprite


# download skia m102
curl -O -L "https://github.com/aseprite/skia/releases/download/m124-08a5439a6b/Skia-macOS-Release-arm64.zip"
unzip Skia-macOS-Release-arm64.zip -d skia-m102
rm Skia-macOS-Release-arm64.zip

# this is the project itselft
url=$(curl -s https://api.github.com/repos/aseprite/aseprite/releases/latest | grep browser_download_url | cut -d '"' -f 4)
filename=$(curl -s https://api.github.com/repos/aseprite/aseprite/releases/latest | grep name | cut -d '"' -f 4 | sed -n 4p)
echo "URL: $url"
echo "File Name: $filename"

# Extract version number from the filename
version=$(echo "$filename" | sed -E 's/Aseprite-(v[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)-Source\.zip/\1/')
echo "Version: $version"


curl -O -L $url
unzip $filename -d aseprite
rm $filename

# compiling aseprite
cd aseprite
mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk -DLAF_BACKEND=skia -DSKIA_DIR=$HOME/Aseprite/skia-m102 -DSKIA_LIBRARY_DIR=$HOME/Aseprite/skia-m102/out/Release-arm64 -DSKIA_LIBRARY=$HOME/Aseprite/skia-m102/out/Release-arm64/libskia.a -DPNG_ARM_NEON:STRING=on -G Ninja ..


ninja aseprite
cd ../..

# bundle app from trial
mkdir bundle
cd bundle
curl -O -J "https://aseprite.org/downloads/trial/Aseprite-${version}-trial-macOS.dmg"
mkdir mount
yes qy | hdiutil attach -quiet -nobrowse -noverify -noautoopen -mountpoint mount Aseprite-${version}-trial-macOS.dmg
cp -r mount/Aseprite.app .
hdiutil detach mount
rm -rf Aseprite.app/Contents/MacOS/aseprite
cp -r ../aseprite/build/bin/aseprite Aseprite.app/Contents/MacOS/aseprite
rm -rf Aseprite.app/Contents/Resources/data
cp -r ../aseprite/build/bin/data Aseprite.app/Contents/Resources/data


# Install on /Applications
sudo cp -R Aseprite.app /Applications/
cd $HOME
rm -rf Aseprite
echo "Please check your 'Applications' folder for Aseprite App"