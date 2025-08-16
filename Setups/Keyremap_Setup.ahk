#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode 2
SetWorkingDir A_ScriptDir "\.."

INSTALL_INTERCEPT_PATH := A_WorkingDir "\Lib\Intercept\Interception\command line installer\install-interception.exe"
iniFilePath := A_WorkingDir "\Lib\Intercept\keyremap.ini"
INTERCEPT := A_WorkingDir "\Lib\Intercept\intercept.exe"
INTERCEPT_PATH := A_WorkingDir "\Lib\Intercept"
KEYREMAP_SETUP_PATH := A_WorkingDir "\Setups\Keyremap_Setup.ahk"
KEYREMAP_SETUP_SHORTCUT_PATH := A_Startup "\Keyremap_Setup.lnk"
MACRO_PAD_SETUP_PATH := A_WorkingDir "\Setups\Macro-Pad_Setup.ahk"
MACRO_PAD := A_WorkingDir "\Macro-Pad.ahk"
MACRO_PAD_SHORTCUT_PATH := A_Startup "\Macro-Pad.lnk"

KeyWaitAny(Options := "") {
    ih := InputHook(Options)
    if !InStr(Options, "V")
        ih.VisibleNonText := false
    ih.KeyOpt("{All}", "E")  ; End
    ih.Start()
    ih.Wait()
    return ih.EndKey  ; Return the key name
}

PromptPress() {
    ToolTip "Press the key on your secondary keyboard and then press {ESC} on your main keyboard a 2 times"
}

result := MsgBox("Do you want to continue with Keyremap Setup?", "Keyremap Setup", "YesNo")
if result = "No" {
    MsgBox("Run the `"" KEYREMAP_SETUP_PATH "`" if you want to continue the setup later", "Keyremap Setup", "OK")
    ExitApp
}

result := MsgBox("Would you like to update the device ID in keyremap.ini?", "Keyremap Setup", "YesNo")
if (result = "No") {
    MsgBox("You can update the keyremap.ini manually by referring the setup guide.", "Keyremap Setup", "Ok")
    ExitApp
}
result := MsgBox(
    "When prompted, gently press the key from the desired keyboared a couple of times (Numpad or Alphabet keys) and then press {ESC} a couple of times",
    "Keyremap Setup",
    "Ok")

; Run intercept.exe to get device ID
Run('cmd.exe /k intercept.exe', INTERCEPT_PATH)
WinWait(" - intercept", , 5)
Sleep 1000
SendInput "a"
SetTimer PromptPress, 1
KeyWaitAny() ; Wait for user to press a key
ToolTip ""
SetTimer PromptPress, 0
Sleep 100
SendInput "getid{Enter}"
SendInput "sqr"
Sleep 100
SendInput "exit{Enter}"

; Read the current keyremap.ini
deviceId := IniRead(iniFilePath, "getid", "device")
regexPattern := "(HID\\VID_\w+&PID_\w+[^`r`n]*)"

; Wrap the keys in F23 using keyremap.ini
newIniContent := FileRead(INTERCEPT_PATH "\backup\keyremap.ini")

newContent := RegExReplace(newIniContent, regexPattern, deviceId)

try {
    FileDelete iniFilePath
}

FileAppend newContent, iniFilePath

try {
    FileDelete KEYREMAP_SETUP_SHORTCUT_PATH
}

MsgBox "The device ID has been updated in keyremap.ini.`n`nYou can now use the keyboard as a macro-pad.",
    "Keyremap Update Successful", "OK"

Run MACRO_PAD_SETUP_PATH

ExitApp

^Esc:: ExitApp