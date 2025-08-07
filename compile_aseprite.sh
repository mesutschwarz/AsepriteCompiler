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

# Download latest release of Skia
skia_url=$(zsh skia-url.sh Release)
skia_file=$(basename $skia_url)
cd $HOME/Aseprite
curl --ssl-revoke-best-effort -L -o "$skia_file" "$skia_url"

unzip "$skia_file" -d skia
rm "$skia_file"


# compiling aseprite
cd aseprite
mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk -DLAF_BACKEND=skia -DSKIA_DIR=$HOME/Aseprite/skia -DSKIA_LIBRARY_DIR=$HOME/Aseprite/skia/out/Release-arm64 -DSKIA_LIBRARY=$HOME/Aseprite/skia/out/Release-arm64/libskia.a -DPNG_ARM_NEON:STRING=on -G Ninja ..


ninja aseprite

cd $HOME/Aseprite

# bundle app from trial

echo "mkdir bundle"
mkdir bundle
cd bundle
echo "Downloading Aseprite trial version..."
curl -O -J "curl -O -J "https://aseprite.org/downloads/trial/Aseprite-${version}-trial-macOS.dmg""
mkdir mount
echo "Mounting Aseprite trial DMG..."
yes qy | hdiutil attach -quiet -nobrowse -noverify -noautoopen -mountpoint mount Aseprite-${version}-trial-macOS.dmg
echo "Copying Aseprite.app from mounted DMG..."
cp -r mount/Aseprite.app .
cd $HOME/Aseprite
echo "Copying aseprite binary to Aseprite.app..."
cp -r aseprite/build/bin/aseprite bundle/Aseprite.app/Contents/MacOS/aseprite
echo "Copying data to Aseprite.app..."
cp -r aseprite/build/bin/data bundle/Aseprite.app/Contents/Resources/data

echo "Installing Aseprite.app to /Applications..."
# Install on /Applications
sudo cp -R bundle/Aseprite.app /Applications/
# Delete the Aseprite directory
rm -rf $HOME/Aseprite
echo "Aseprite installation complete."
echo "Please check your 'Applications' folder."