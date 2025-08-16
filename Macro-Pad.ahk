; // cspell:disable (This is for disabling the spell check in VSCode)
#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "DynamicNumpad.ahk"  ; Include the refactored class for GUI and visuals

; === Global variables ===
global numpadGui := ""                  ; Holds the GUI object
global numpadLayers := 4                 ; Number of layers (sets of macros)
global currentLayer := 2                 ; Currently active layer
global interceptEnabled := false         ; Whether interception is enabled

; =======================
; Configuration
; =======================7
; Key used to determine if key is intercepted
INTERCEPT_KEY := "F23"                   ; Modifier key for identifying input from the macro pad
INTERCEPT := A_WorkingDir "\Lib\Intercept\intercept.exe"   ; Path to intercept.exe
INTERCEPT_PATH := A_WorkingDir "\Lib\intercept"            ; Path to intercept folder

; =======================
; Main Script
; =======================

; Initialize the script and show the GUI
InitScript()

; Set up cleanup when script exits
OnExit(ExitFunc)

; =======================
; Functions
; =======================

/**
 * Cleanup function called when the script exits
 * Ensures the Interception driver is properly closed
 */
ExitFunc(ExitReason, ExitCode) {
    ; Close the Interception driver
    DisableInterception()
    ; Clean up any remaining tooltips
    ToolTip ""
}

/**
 * Disables and closes the Interception driver
 */
DisableInterception() {
    try {
        ; Kill any existing intercept processes
        RunWait('cmd.exe /c taskkill /IM intercept.exe /F', , "Hide")
        interceptEnabled := false
    } catch as err {
        ; Silently fail on exit - user might have already closed it
    }
}

/**
 * Initializes the script, enables interception, and shows the GUI for the current layer
 */
InitScript() {
    ; Start the interception driver
    EnableInterception()
    ; Show the numpad GUI with the current layer (only if visualization is enabled)
    ShowNumpadGUI(currentLayer)
}

/**
 * Checks if the interception driver is running
 */
IsInterceptRunning() {
    return ProcessExist("intercept.exe")
}

/**
 * Enables the interception driver (for advanced key remapping)
 */
EnableInterception() {
    try {
        ; Kill any existing intercept processes
        RunWait('cmd.exe /c taskkill /IM intercept.exe /F', , "Hide")
        ; Run the intercept driver
        Run('cmd.exe /c ' INTERCEPT ' /apply', INTERCEPT_PATH, "Hide")
        interceptEnabled := true
    } catch as err {
        MsgBox("Failed to start interception: " err.Message "`n`nPlease make sure intercept.exe is installed in: " INTERCEPT_PATH
        )
        ExitApp
    }
}

/**
 * Shows the numpad GUI for the specified layer
 * @param layer Which layer to show
 * @param timeout Optional: how long to show the GUI
 * @param iniFile Optional: custom INI file for images
 */
ShowNumpadGUI(layer, timeout := -1, iniFile := "") {
    global currentLayer, numpadGui

    ; Check if visualization is enabled in settings
    visualizationEnabled := true
    try {
        visualizationEnabled := IniRead("numpad_settings.ini", "Settings", "ShowMacroPadGui", "true")
        visualizationEnabled := (visualizationEnabled = "true")
    } catch {
        visualizationEnabled := true ; Default to true if there's an error reading the setting
    }

    ; Destroy existing GUI if it exists
    if (numpadGui != "") {
        try {
            numpadGui.gui.Destroy()
        } catch {
        }
        numpadGui := ""
    }

    ; Only create and show GUI if visualization is enabled
    if (visualizationEnabled) {
        ; Create a new GUI with the specified layer
        numpadGui := DynamicNumpad(iniFile, timeout, layer)
    }
    ; Show current layer in tooltip
    ShowLayerTooltip()
}

/**
 * Shows a tooltip with the current layer number
 */
ShowLayerTooltip() {
    ; Always show tooltips regardless of GUI visibility setting
    ToolTip "Layer: " currentLayer
    SetTimer ToolTip, -500
}

RemoveToolTip() {
    ToolTip ""
}

/**
 * Returns true if the interception key is pressed (i.e., input is from macro pad)
 */
IsIntercepted() {
    return GetKeyState(INTERCEPT_KEY, "P")
}

/**
 * Returns true if we're in a specific layer and interception is active
 * Used for conditional hotkeys below
 */
numpadLayer1() {
    global currentLayer
    return (currentLayer == 1 and IsIntercepted())
}
numpadLayer2() {
    global currentLayer
    return (currentLayer == 2 and IsIntercepted())
}
numpadLayer3() {
    global currentLayer
    return (currentLayer == 3 and IsIntercepted())
}
numpadLayer4() {
    global currentLayer
    return (currentLayer == 4 and IsIntercepted())
}

; =======================
; Hotkeys
; =======================

; --- Layer switching hotkeys (work in any layer) ---
#HotIf IsIntercepted()

; Numpad / : Go to previous layer
NumpadDiv:: {
    global currentLayer
    currentLayer := currentLayer = 1 ? numpadLayers : currentLayer - 1
    ShowNumpadGUI(currentLayer)
}

; Numpad * : Show GUI for current layer (with timeout)
NumpadMult:: {
    global currentLayer
    ShowNumpadGUI(currentLayer, numpadLayers + 1)
}

; Numpad - : Go to next layer
NumpadSub:: {
    global currentLayer
    currentLayer := Mod(currentLayer, numpadLayers) + 1
    ShowNumpadGUI(currentLayer)
}

; --- Macro assignments for each layer ---

; Layer 1: Default Numpad (pass-through keys)
#HotIf numpadLayer1()
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
; NumpadSub::
; NumpadMult::
; NumpadDiv::
NumpadEnter:: Send("{" A_ThisHotKey "}") ; Pass through key
; Layer 2: Application Launcher
#HotIf numpadLayer2()
Numpad1:: Run("notepad.exe")         ; Launch Notepad
Numpad2:: Run("calc.exe")            ; Launch Calculator
Numpad3::
Numpad4::
Numpad5::
Numpad6::
Numpad7::
Numpad8::
Numpad9::
Numpad0::
NumpadDot::
NumpadAdd:: {
    ToolTip "Layer: " currentLayer " - Key {" A_ThisHotkey "}"
    SetTimer ToolTip, -500
}
; NumpadSub::
; NumpadMult::
; NumpadDiv::
NumpadEnter::Media_Play_Pause

; Layer 3: Example Text Macros
#HotIf numpadLayer3()
Numpad1:: Send("Hello, world!")      ; Send text
Numpad2:: Send("Your email@example.com")
Numpad3::
Numpad4::
Numpad5::
Numpad6::
Numpad7::
Numpad8::
Numpad9::
Numpad0::
NumpadDot::
NumpadAdd:: {
    ToolTip "Layer: " currentLayer " - Key {" A_ThisHotkey "}"
    SetTimer ToolTip, -500
}
; NumpadSub::
; NumpadMult::
; NumpadDiv::
NumpadEnter::Media_Play_Pause

; Layer 4: Custom Layer (add your own macros)
#HotIf numpadLayer4()
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
NumpadAdd:: {
    ToolTip "Layer: " currentLayer " - Key {" A_ThisHotkey "}"
    SetTimer ToolTip, -500
}
; NumpadSub::
; NumpadMult::
; NumpadDiv::
NumpadEnter::Media_Play_Pause

#HotIf  ; End conditional hotkeys
