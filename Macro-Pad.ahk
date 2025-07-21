#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "DynamicNumpad.ahk"  ; Include the refactored class

; Global variables
global numpadGui := ""
global numpadLayers := 4
global currentLayer := 1
global interceptEnabled := false

; =======================
; Configuration
; =======================7
; Key used to determine if key is intercepted
INTERCEPT_KEY := "F23"
INTERCEPT := A_WorkingDir "\Lib\Intercept\intercept.exe"
INTERCEPT_PATH := A_WorkingDir "\Lib\intercept"

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
    ; if (!IsInterceptRunning()) {
    EnableInterception()
    ; }

    ; Show the numpad GUI with the current layer
    ShowNumpadGUI(currentLayer)

}

/**
 * Check if the interception driver is running
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
        Run('cmd.exe /c ' INTERCEPT ' /apply', INTERCEPT_PATH, "Hide")
        interceptEnabled := true
        ; ToolTip "Interception Successfully Enabled"
        ; SetTimer RemoveToolTip, -500
    } catch as err {
        MsgBox("Failed to start interception: " err.Message "`n`nPlease make sure intercept.exe is installed in: " INTERCEPT_PATH
        )
        ExitApp
    }
}

/**
 * Show the numpad GUI with the specified layer
 */
ShowNumpadGUI(layer, timeout := -1, iniFile := "") {
    global currentLayer, numpadGui

    ; Destroy existing GUI if it exists
    if (numpadGui != "") {
        try {
            numpadGui.gui.Destroy()
        } catch {
        }
    }

    ; Create a new GUI with the specified layer
    numpadGui := DynamicNumpad(iniFile, timeout, layer)

    ; Show current layer in tooltip
    ShowLayerTooltip()
}

/**
 * Show a tooltip with the current layer
 */
ShowLayerTooltip() {
    ToolTip "Layer: " currentLayer
    SetTimer ToolTip, -500
}

RemoveToolTip() {
    ToolTip ""
}

/**
 * Check if keys are currently being intercepted
 */
IsIntercepted() {
    return GetKeyState(INTERCEPT_KEY, "P")
}

/**
 * Check if we're in a specific layer with interception active
 */
numpadLayer1() {
    global currentLayer
    if (currentLayer == 1 and IsIntercepted) {
        return true
    }
    else {
        return false
    }
}

numpadLayer2() {
    global currentLayer
    if (currentLayer == 2 and IsIntercepted) {
        return true
    }
    else {
        return false
    }
}

numpadLayer3() {
    global currentLayer
    if (currentLayer == 3 and IsIntercepted) {
        return true
    }
    else {
        return false
    }
}

numpadLayer4() {
    global currentLayer

    if (currentLayer == 4 and IsIntercepted) {
        return true
    }
    else {
        return false
    }
}

; =======================
; Hotkeys
; =======================

; Layer switching hotkeys
#HotIf IsIntercepted()

; Decrement layer (/ key)
NumpadDiv:: {
    global currentLayer
    currentLayer := currentLayer = 1 ? numpadLayers : currentLayer - 1
    ShowNumpadGUI(currentLayer)
}

; Show GUI with timeout (* key)
NumpadMult:: {
    global currentLayer
    ShowNumpadGUI(currentLayer, numpadLayers + 1)
}

; Increment layer (- key)
NumpadSub:: {
    global currentLayer
    currentLayer := Mod(currentLayer, numpadLayers) + 1
    ShowNumpadGUI(currentLayer)
}

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
NumpadEnter:: Send("{" A_ThisHotKey "}")

; Layer 2: Application Launcher
#HotIf numpadLayer2()
Numpad1::Run("notepad.exe")
Numpad2::Run("calc.exe")
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
NumpadEnter:: {
    ToolTip "Layer: " currentLayer " - Key {" A_ThisHotkey "}"
    SetTimer ToolTip, -500
}

; Layer 3: YouTube Tools
#HotIf numpadLayer3()
Numpad1::Send("Hello, world!")
Numpad2::Send("Your email@example.com")
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
NumpadEnter:: {
    ToolTip "Layer: " currentLayer " - Key {" A_ThisHotkey "}"
    SetTimer ToolTip, -500
}

; Layer 4: Custom Layer
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
NumpadAdd::
; NumpadSub::
; NumpadMult::
; NumpadDiv::
NumpadEnter:: {
    ToolTip "Layer: " currentLayer " - Key {" A_ThisHotkey "}"
    SetTimer ToolTip, -500
}

#HotIf  ; End conditional hotkeys
