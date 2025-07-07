# Dynamic Numpad Macro System (Under Developement)

## V1 Available to use

Turn your numpad into a customizable macro pad with multiple layers and visual feedback.

## Installation

<!-- In the [Visual C++ Redistributable Runtimes All-in-One](https://www.techpowerup.com/download/visual-c-redistributable-runtime-package-all-in-one/) -->

### Open powershell (at your desired location) and paste this commands
    $repo = "Shamil-Xero/MacroPad"
    $url = "https://github.com/$repo/archive/refs/heads/main.zip"
    $zip = ".\MacroPad.zip"
    $dest = ".\MacroPad"
    $main = ".\MacroPad-main"

    # Installing AHK
    winget install autohotkey.autohotkey --accept-package-agreements --accept-source-agreements --silent

    # Download and extract
    Invoke-WebRequest -Uri $url -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath .\ -Force
    Remove-Item $zip -Force
    Rename-Item -Path "$main" -NewName $dest

    # Run setup
    Start-Process "$dest\setup.ahk"

    # Exit script
    exit
    

## Features

- Multiple layers of macros (4 modes)
- Visual interface showing assigned functions
- Customizable button images
- Adjustable transparency and appearance
- Auto fade-in/fade-out


