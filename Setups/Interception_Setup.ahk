#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode 2
SetWorkingDir A_ScriptDir "\.."

INSTALL_INTERCEPT_PATH := A_WorkingDir "\Lib\Intercept\Interception\command line installer"
iniFilePath := A_WorkingDir "\Lib\Intercept\keyremap.ini"
INTERCEPT := A_WorkingDir "\Lib\Intercept\intercept.exe"
INTERCEPT_PATH := A_WorkingDir "\Lib\intercept"
KEYREMAP_SETUP_PATH := A_WorkingDir "\Setups\Keyremap_Setup.ahk"
KEYREMAP_SETUP_SHORTCUT_PATH := A_Startup "\Keyremap_Setup.lnk"
MACRO_PAD_SETUP_PATH := A_WorkingDir "\Setups\Macro-Pad_Setup.ahk"
MACRO_PAD := A_WorkingDir "\Macro-Pad.ahk"
MACRO_PAD_SHORTCUT_PATH := A_Startup "\Macro-Pad.lnk"

; Run intercept.exe with /install parameter
Runwait(A_WorkingDir "\Setups\vcredist_x86.exe")
Runwait(A_WorkingDir "\Setups\vcredist_x64.exe")
Runwait('*RunAs cmd.exe /c cd /d ' INSTALL_INTERCEPT_PATH ' && install-interception.exe /install', , "Hide")

; Show message to user
result := MsgBox(
    "The system needs to be restarted to continue the setup,`n`nDo you want to restart the system now`n(Don't forget to save you work!)",
    "Interception Setup", "YesNo")

if result = "Yes" {
    result := MsgBox(
        "The Keyremap setup will start automatically after the restart.`n`nPress ok when ready to restart!!",
        "Interception Setup", "OKCancel")
    if result = "OK" {
        FileCreateShortcut "cmd.exe", KEYREMAP_SETUP_SHORTCUT_PATH, A_WorkingDir "\", "/c `"" KEYREMAP_SETUP_PATH "`"",
            "To run keyremap setup", , , , 7
        Run 'cmd /c Shutdown /r /t 0', , "Hide"
        ; MsgBox("Restarted")
        ExitApp
    }
}

result := MsgBox(
    "Run the `"" KEYREMAP_SETUP_PATH "`" file after restarting to continue with the setup whenever you want",
    "Interception Setup", "OK")

ExitApp

^Esc:: ExitApp