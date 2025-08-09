# Dynamic Numpad Macro System (Under Developement)

## V1 Available to use

Turn your numpad into a customizable macro pad with multiple layers and visual feedback.

## Installation

Follow these steps to install the Dynamic Numpad Macro System:

### 1. Install AutoHotkey

If you don’t already have AutoHotkey installed, please install it first:

- **Recommended:**  
  Open PowerShell and run:
  ```powershell
  winget install autohotkey.autohotkey --accept-package-agreements --accept-source-agreements --silent
  ```
- Or, download and install it from [autohotkey.com](https://www.autohotkey.com/).

---

### 2. Download the Repository

You can use the following PowerShell script to download and extract the latest version of this repository:

```powershell
# Set variables
$repo = "Shamil-Xero/MacroPad"
$url = "https://github.com/$repo/archive/refs/heads/main.zip"
$zip = ".\MacroPad.zip"
$main = ".\MacroPad-main"
$dest = ".\MacroPad"

# Download the ZIP file
Invoke-WebRequest -Uri $url -OutFile $zip

# Extract the ZIP file
Expand-Archive -Path $zip -DestinationPath .\ -Force

# Remove the ZIP file
Remove-Item $zip -Force

# Rename the extracted folder to 'MacroPad'
if (Test-Path $main) {
    Rename-Item -Path $main -NewName $dest
}
```

After running this script, you will have a `MacroPad` folder in your current directory containing all the necessary files.

---

### 3. Run the Setup Script

- In the extracted `MacroPad` folder, run the setup script:
  - Double-click `MacroPad_Setup.ahk`  
    **or**
  - Run in PowerShell:
    ```powershell
    Start-Process ".\MacroPad_Setup.ahk"
    ```

---

### 4. Automatic Dependency Installation

- The setup script will automatically:
  - Install the required Visual C++ Redistributables (from the `Setups/` folder)
  - Launch the Interception driver installer (from `Lib/Intercept/Interception/command line installer/`)
- **Follow any on-screen instructions.**  
  You may be prompted for administrator permissions and/or to restart your computer.

## Configuration

The Dynamic Numpad Macro System separates visual customization from macro and layer logic:

### Visual Customization
- **File:** `numpad_settings.ini`
- **Purpose:** Controls the appearance and layout of the on-screen numpad.
- **Editable Options:**
  - Colors (background, button, title bar)
  - Button size and font
  - Window size and position
  - Transparency
  - Image INI files for button images (e.g., `ImagesIniFile1`, `ImagesIniFile2`, etc.)
  - **`ShowMacroPadVisualization`**: Set to `true` to display the GUI, `false` to hide it completely
- **How to Edit:**
  Open `numpad_settings.ini` in a text editor, adjust the values under `[Settings]`, save, and restart the macro pad to see changes.

### Macro and Layer Customization
- **File:** `Macro-Pad.ahk`
- **Purpose:** All macro assignments and layer logic are defined directly in this script.
- **How to Edit Macros and Layers:**
  1. Open `Macro-Pad.ahk` in a text editor.
  2. Scroll to the section labeled `; ======================= Hotkeys =======================`.
  3. Each layer is defined using `#HotIf numpadLayerX()` (where X is the layer number).
  4. Under each layer, assign actions to numpad keys. For example:
     ```ahk
     #HotIf numpadLayer2()
     Numpad1::Run("notepad.exe")
     Numpad2::Send("Hello World!")
     ```
  5. Save the file and restart `MacroPad.ahk` to apply your changes.
- **Layer Switching:**
  - **Numpad /** : Previous layer
  - **Numpad \*** : Show current layer
  - **Numpad -** : Next layer
- **Tip:**
  You can define up to 4 layers by default. To add more, adjust the `global numpadLayers := 4` line and add corresponding `numpadLayerX()` and `#HotIf numpadLayerX()` blocks.

#### Example: Customizing Macros for Each Layer

```ahk
; ======================= Hotkeys =======================

; Layer 1: Default Numpad (pass-through keys)
#HotIf numpadLayer1()
Numpad1::Send("{Numpad1}")
Numpad2::Send("{Numpad2}")
; ...add more keys as needed

; Layer 2: Application Launcher
#HotIf numpadLayer2()
Numpad1::Run("notepad.exe")
Numpad2::Run("calc.exe")
; ...add more keys as needed

; Layer 3: Text Macros
#HotIf numpadLayer3()
Numpad1::Send("Hello, world!")
Numpad2::Send("Your email@example.com")
; ...add more keys as needed

; Layer 4: Custom Shortcuts
#HotIf numpadLayer4()
Numpad1::Send("^c") ; Copy
Numpad2::Send("^v") ; Paste
; ...add more keys as needed

#HotIf  ; End conditional hotkeys
```

---

## Features

The Dynamic Numpad Macro System offers a range of features to enhance your workflow:

- **Multiple Macro Layers**
  - Switch between up to 4 (or more) layers, each with its own set of macros.
  - Quickly change layers using Numpad /, *, and - keys.
- **Visual Interface**
  - On-screen numpad shows current layer and assigned keys.
  - Visual feedback for key presses and active macros.
  - Can be completely disabled via `ShowMacroPadVisualization` setting in `numpad_settings.ini`.
- **Custom Button Images**
  - Assign images to buttons for each layer using the image INI files referenced in `numpad_settings.ini`.
  - Supported image formats: PNG, JPG, BMP, etc.
- **Adjustable Appearance**
  - Change colors, transparency, button size, and font via `numpad_settings.ini`.
  - Move and resize the window as needed.

---

## Troubleshooting

**Common Issues and Solutions:**

### The macro pad doesn’t appear or crashes on launch
- Make sure you have installed AutoHotkey v2.0 or later.
- Ensure all files are in the correct directory structure as provided in the repository.
- Try running `MacroPad.ahk` as administrator.

### Macros or layers are not working as expected
- Double-check your edits in `Macro-Pad.ahk` for syntax errors.
- After making changes, always save the file and restart the script.
- Ensure you are switching layers using the correct keys (Numpad /, *, -).

### Visual changes are not applied
- Edit and save `numpad_settings.ini`, then restart the macro pad.

### The GUI doesn't appear at all
- Check the `ShowMacroPadVisualization` setting in `numpad_settings.ini` - it should be set to `true`.
- If set to `false`, the macro pad will work but without visual feedback.

### Interception driver issues
- The Interception driver may require administrator rights and a system restart after installation.
- If keys are not being intercepted, rerun the setup or check your device configuration in `keyremap.ini`.

### Still having trouble?
- Check for error messages or pop-ups for more information.
- Consult the [GitHub Issues page](https://github.com/Shamil-Xero/MacroPad/issues) for help or to report bugs.

---

## Contributing

**Want to help improve the Dynamic Numpad Macro System?**

Contributions are welcome! Here’s how you can get involved:

- **Report Bugs:**  
  If you find a bug or have a feature request, please open an issue on the [GitHub Issues page](https://github.com/Shamil-Xero/MacroPad/issues).

- **Submit Pull Requests:**  
  If you’d like to contribute code, fork the repository, make your changes, and submit a pull request. Please provide a clear description of your changes.

- **Suggest Improvements:**  
  Feedback and suggestions are always appreciated! Feel free to start a discussion or comment on existing issues.

---

## License

This project is licensed under the MIT License.  
See the `LICENSE` file in the repository for details.

---

## Acknowledgements

- **Interception Driver:**  
  Special thanks to [Francisco Lopes (oblitum)](https://github.com/oblitum/Interception) for the [Interception driver](https://github.com/oblitum/Interception), which makes advanced keyboard remapping possible.

- **Inspiration:**  
  Huge shoutout to [Taran Van Hemert](https://github.com/TaranVH/2nd-keyboard) for his pioneering work and open sharing of scripts and ideas for multi-keyboard macro systems.

