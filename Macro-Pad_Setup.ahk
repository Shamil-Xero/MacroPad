#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode 2
SetWorkingDir A_ScriptDir

INSTALL_INTERCEPT_PATH := A_WorkingDir "\Lib\Intercept\Interception\command line installer\install-interception.exe"
iniFilePath := A_WorkingDir "\Lib\Intercept\keyremap.ini"
INTERCEPT := A_WorkingDir "\Lib\Intercept\intercept.exe"
INTERCEPT_PATH := A_WorkingDir "\Lib\intercept"
KEYREMAP_SETUP_PATH := A_WorkingDir "\Keyremap_Setup.ahk"
KEYREMAP_SETUP_SHORTCUT_PATH := A_Startup "\Keyremap_Setup.lnk"
MACRO_PAD_SETUP_PATH := A_WorkingDir "\Macro-Pad_Setup.ahk"
MACRO_PAD := A_WorkingDir "\Macro-Pad.ahk"
MACRO_PAD_SHORTCUT_PATH := A_Startup "\Macro-Pad.lnk"

result := MsgBox("Do you want to run the Macro-Pad script automatically at startup?", "Macro-Pad Setup", "YesNo")
if result = "Yes" {
    FileCreateShortcut MACRO_PAD, MACRO_PAD_SHORTCUT_PATH, A_WorkingDir, A_WorkingDir, "Macro-Pad Autostart", , , ,
        7

    MsgBox("A shortcut for the Macro-Pad script has been created in the startup folder.", "Macro-Pad Setup", "OK")
}
result := MsgBox("Do you want to start the Macro-Pad script now?", "Macro-Pad Setup", "YesNo")
if result = "No" {
    MsgBox("You can start the script from`n`n" MACRO_PAD, "Macro-Pad Setup", "OK")
}

Run MACRO_PAD

ExitApp

^Esc:: ExitApp