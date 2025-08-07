# Aseprite Compiler for macOS (ARM64) 

## Compiling Aseprite on macOS Apple Silicon 💻

This script automates the entire process of compiling the latest version of **Aseprite** from its source code for macOS with Apple Silicon (M-series) chips. It handles all necessary dependencies, downloads (including the latest Skia release automatically), and compilation steps, resulting in a fully working Aseprite application ready to be used.

It copies the fully compiled and bundled Aseprite application to the `/Applications` folder, making it available system-wide.

On my 2020 Macbook Air M1 computer, Homebrew and Xcode.app were installed and all operations took 5m 21s (including downloading things).

### Prerequisites

  *  **Silicon CPU Support:** The script is designed to work on macOS systems with Apple Silicon (M1, M2, etc.) chips.

  * **Full Xcode.app:** The script requires the full Xcode application to be installed in `/Applications/Xcode.app`. The Xcode Command Line Tools alone are not sufficient. Please install Xcode from the App Store before running the script.

  * **Homebrew:** The script will automatically install Homebrew if it's not present on your system. However, for a smoother experience, it's recommended to install it beforehand.

-----

### How to Use the Script

1.  **Save the script:** Copy the provided script and save it as a file named `compile_aseprite.sh`.
2.  **Make it executable:** Open your Terminal and make the script executable with the following command:
    ```bash
    chmod +x compile_aseprite.sh
    ```
3.  **Run the script:** Execute the script from your Terminal. It will ask for your password to install the final application into your `/Applications` folder.
    ```bash
    ./compile_aseprite.sh
    ```

-----

### What the Script Does

The script performs the following actions in a sequential order:

1.  **Checks for Xcode.app:** The script will exit if the full Xcode application is not installed in `/Applications/Xcode.app`.
2.  **Installs Homebrew** (if not already installed). Homebrew is a package manager for macOS that simplifies the installation of software.
3.  **Installs Dependencies:** It uses Homebrew to install **Ninja** and **CMake**, which are essential tools for building Aseprite.
4.  **Sets up the Workspace:** It creates a dedicated directory at `~/Aseprite` to download all necessary files and perform the compilation.
5.  **Downloads Skia Automatically:** It fetches the latest compatible Skia macOS release automatically, ensuring you always build with the most up-to-date graphics library.
6.  **Downloads Aseprite Source Code:** It automatically fetches the latest stable release of the Aseprite source code from GitHub.
7.  **Compiles Aseprite:** Using **CMake** and **Ninja**, the script compiles the Aseprite source code into a binary executable optimized for Apple Silicon architecture (`arm64`).
8.  **Bundles the Application:** It downloads a trial version of Aseprite to create the application bundle structure (`Aseprite.app`). It then replaces the trial's executable and data with the newly compiled versions.
9.  **Installs Aseprite:** Finally, it copies the fully compiled and bundled Aseprite application to the `/Applications` folder, making it available system-wide.
10.  **Cleans Up:** It removes the temporary `~/Aseprite` directory to save disk space.

-----

### Troubleshooting

If you encounter any issues during the compilation process, consider the following:

  * **Xcode.app Required:** If Xcode.app is not installed, the script will exit and prompt you to install it from the App Store.
  * **Internet Connection:** Ensure you have a stable internet connection for downloading the necessary files.
  * **Permissions:** The script will prompt for your password when installing the application. Make sure you enter it correctly.
  * **Hardcoded paths:** The script assumes the default Xcode installation path: `/Applications/Xcode.app`. If your Xcode is installed in a different location, you'll need to modify the `cmake` command in the script accordingly.
  * **Aseprite Not Running:** When you run the script, make sure that Aseprite is not running. If it is, the script will fail to copy the new version into the `/Applications` folder.