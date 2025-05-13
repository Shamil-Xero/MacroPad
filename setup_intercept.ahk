#Requires AutoHotkey v2.0
#SingleInstance Force

; Set working directory to script's location
SetWorkingDir A_ScriptDir

; Run intercept.exe with /install parameter
INSTALL_INTERCEPT_PATH := A_WorkingDir "\Intercept\Interception\command line installer\install-interception.exe"
INTERCEPT_PATH := A_WorkingDir "\intercept\intercept.exe"

; Runwait "*RunAs cmd.exe /c `"" INSTALL_INTERCEPT_PATH "`" /install", ,"Hide"

; Show message to user

result := MsgBox(
    "Would you like to continue the Interception Setup?`n`nYou can continue the setup later by running the " A_ScriptDir "\Setup2.ahk",
    "Interception Setup", "YesNo")
if (result = "Yes") {
    result := MsgBox(
        "Would you like to update the device ID in keyremap.ini?`n`nThis will require you to press a key from your keyboard.",
        "Interception Setup", "YesNo")
}
if (result = "No")
    ExitApp

; Run intercept.exe to get device ID
Run INTERCEPT_PATH
Sleep 1000
SendInput "l"
/*

; Show instructions
MsgBox "Please press any key from the keyboard you want to use.`n`nThe device ID will be displayed in the console window.",
"Device ID Setup"

; Wait for user to press a key
deviceID := InputBox("Press a key from your keyboard", "Device ID Setup").Value

; Read the current keyremap.ini
iniContent := FileRead("keyremap.ini")

; Replace the device ID in the ini file using regex
; Pattern matches HID\VID_xxxx&PID_xxxx&REV_xxxx&MI_xx format
newIniContent := RegExReplace(iniContent, "HID\\VID_[0-9A-F]{4}&PID_[0-9A-F]{4}&REV_[0-9A-F]{4}&MI_[0-9A-F]{2}",
deviceID)

; Write the updated content back to the file
FileDelete "keyremap.ini"
FileAppend "keyremap.ini", newIniContent

MsgBox "The device ID has been updated in keyremap.ini.`n`nYou can now use the keyboard with Interception.",
"Setup Complete"

*/
ExitApp