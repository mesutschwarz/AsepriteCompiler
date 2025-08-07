# Windows PowerShell script to compile Aseprite for Windows x64
# Requires: Chocolatey, Ninja, CMake, 7zip

# Check for Chocolatey, install if missing
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install required tools
choco install ninja cmake 7zip.commandline -y

# Create working directory
$AsepriteDir = "$env:USERPROFILE\Aseprite"
New-Item -ItemType Directory -Force -Path $AsepriteDir | Out-Null
Set-Location $AsepriteDir

# Download Skia for Windows x64
$skiaUrl = "https://github.com/aseprite/skia/releases/download/m124-08a5439a6b/Skia-Windows-Release-x64.zip"
Invoke-WebRequest -Uri $skiaUrl -OutFile "Skia-Windows-Release-x64.zip"
7z x Skia-Windows-Release-x64.zip -o"skia-m124"
Remove-Item Skia-Windows-Release-x64.zip

# Download latest Aseprite source
$releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/aseprite/aseprite/releases/latest"
$url = ($releaseInfo.assets | Where-Object { $_.name -like "Aseprite-*-Source.zip" }).browser_download_url
$filename = ($releaseInfo.assets | Where-Object { $_.name -like "Aseprite-*-Source.zip" }).name
Write-Host "URL: $url"
Write-Host "File Name: $filename"

# Extract version number
$version = ($filename -replace "Aseprite-(v[\d\.]+)-Source.zip", '$1')
Write-Host "Version: $version"

Invoke-WebRequest -Uri $url -OutFile $filename
7z x $filename -o"aseprite"
Remove-Item $filename

# Compile Aseprite
Set-Location "$AsepriteDir\aseprite"
New-Item -ItemType Directory -Force -Path "build" | Out-Null
Set-Location "build"

cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLAF_BACKEND=skia -DSKIA_DIR="$AsepriteDir\skia-m124" -DSKIA_LIBRARY_DIR="$AsepriteDir\skia-m124\out\Release-x64" -DSKIA_LIBRARY="$AsepriteDir\skia-m124\out\Release-x64\skia.lib" -G Ninja ..
ninja aseprite

Write-Host "Build complete. Find aseprite.exe in $AsepriteDir\aseprite\build\bin"
