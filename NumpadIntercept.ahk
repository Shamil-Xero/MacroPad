#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "DynamicNumpad.ahk"  ; Include the refactored class

; Global variables
global numpadGui := ""
global currentMode := 1
global interceptEnabled := false

; =======================
; Configuration
; =======================
; Path to intercept.exe (adjust if needed)
INTERCEPT_PATH := A_ScriptDir "\intercept\intercept.exe"

; Key used to determine if key is intercepted
INTERCEPT_KEY := "F23"

; =======================
; Main Script
; =======================

; Initialize the script
InitScript()

; =======================
; Functions
; =======================

/**
 * Initialize the script and setup the environment
 */
InitScript() {
    ; Start the interception driver if not already running
    if (!IsInterceptRunning()) {
        EnableInterception()
    }

    ; Show the numpad GUI with the current mode
    ShowNumpadGUI(currentMode)

    ; Show a brief tooltip to confirm the mode
    ShowModeTooltip()
}

/**
 * Check if the interception driver is running
 * @returns {Boolean} - True if running, false otherwise
 */
IsInterceptRunning() {
    return ProcessExist("intercept.exe")
}

/**
 * Enable the interception driver
 */
EnableInterception() {
    try {
        ; Kill any existing intercept processes
        RunWait('cmd.exe /c taskkill /IM intercept.exe /F', , "Hide")

        ; Run the intercept driver
        Run('cmd.exe /c "' INTERCEPT_PATH '" /apply', , "Hide")

        interceptEnabled := true
    } catch as err {
        MsgBox("Failed to start interception: " err.Message "`n`nPlease make sure intercept.exe is installed in: " INTERCEPT_PATH
        )
        ExitApp
    }
}

/**
 * Show the numpad GUI with the specified mode
 * @param {Integer} mode - The mode to display (1-4)
 * @param {Integer} timeout - Seconds before GUI fades out (-1 to use default)
 * @param {String} iniFile - Optional custom INI file path
 */
ShowNumpadGUI(mode, timeout := -1, iniFile := "") {
    global currentMode, numpadGui

    ; Destroy existing GUI if it exists
    if (numpadGui != "") {
        try {
            numpadGui.gui.Destroy()
        } catch {
        }
    }

    ; Create a new GUI with the specified mode
    numpadGui := DynamicNumpad(iniFile, timeout, mode)

    ; Show current mode in tooltip
    ShowModeTooltip()
}

/**
 * Show a tooltip with the current mode
 */
ShowModeTooltip() {
    ToolTip "Mode: " currentMode
    SetTimer () => ToolTip(), -500
}

/**
 * Check if keys are currently being intercepted
 * @returns {Boolean} - True if intercepted, false otherwise
 */
IsIntercepted() {
    return GetKeyState(INTERCEPT_KEY, "P")
}

/**
 * Check if we're in a specific mode with interception active
 * @param {Integer} mode - The mode to check for
 * @returns {Boolean} - True if in specified mode with interception, false otherwise
 */
InNumpadMode(mode) {
    global currentMode
    return (currentMode == mode && IsIntercepted())
}

/**
 * Run application if it's not already running, otherwise focus it
 * @param {String} windowTitle - Window title to search for
 * @param {String} appPath - Path to the application executable
 */
RunApplication(windowTitle, appPath) {
    if (WinExist(windowTitle)) {
        WinActivate
    } else {
        Run appPath
    }
}

; =======================
; Hotkeys
; =======================

; Mode switching hotkeys
#HotIf IsIntercepted()

; Decrement mode (/ key)
NumpadDiv:: {
    global currentMode
    currentMode := currentMode = 1 ? 4 : currentMode - 1
    ShowNumpadGUI(currentMode)
}

; Show GUI with timeout (* key)
NumpadMult:: {
    global currentMode
    ShowNumpadGUI(currentMode, 5)
}

; Increment mode (- key)
NumpadSub:: {
    global currentMode
    currentMode := Mod(currentMode, 4) + 1
    ShowNumpadGUI(currentMode)
}

; Mode 1: Default Numpad (pass-through keys)
#HotIf InNumpadMode(1)
Numpad1::
Numpad2::
Numpad3::
Numpad4::
Numpad5::
Numpad6::
Numpad7::
Numpad8::
Numpad9::
Numpad0::
NumpadDot::
NumpadAdd::
NumpadSub::
NumpadMult::
NumpadDiv::
NumpadEnter:: Send "{" A_ThisHotkey "}"

; Mode 2: Application Launcher
#HotIf InNumpadMode(2)
NumpadEnter::Media_Play_Pause

Numpad7:: RunApplication("Microsoft​ Edge", "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe")
Numpad8:: RunApplication("Brave", "C:\Users\USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Brave.lnk")
Numpad9:: RunApplication("Spotify", "C:\Users\USERNAME\AppData\Roaming\Spotify\Spotify.exe")
NumpadAdd:: RunApplication("Visual Studio Code", "C:\Users\USERNAME\AppData\Local\Programs\Microsoft VS Code\Code.exe")

Numpad4:: {
    ; Example of a custom action
    Run("https://www.youtube.com/", , "max")
}

Numpad5:: RunApplication(" - File Explorer", "explorer.exe")

; Mode 3: YouTube Tools
#HotIf InNumpadMode(3)
Numpad7:: Run "D:\Programs\AHK.code-workspace"
Numpad8:: Run "D:\Programs\Python-Scripts.code-workspace"
Numpad9:: Run 'cmd /c Shutdown /r /t 0', , "Hide"  ; Restart
NumpadAdd:: Run 'cmd /c Shutdown /s /t 0', , "Hide"  ; Shutdown

; Mode 4: Custom Mode
#HotIf InNumpadMode(4)
; Add your custom hotkeys for mode 4 here

#HotIf  ; End conditional hotkeys
