#Requires AutoHotkey v2.0
#SingleInstance Force
; HID Detector for AHK v2
; Press F1 to detect the HID of your keyboard device

; Constants for Raw Input
RIDEV_INPUTSINK := 0x00000100
RID_INPUT := 0x10000003
RIM_TYPEKEYBOARD := 1
RIM_TYPEMOUSE := 2
RIDI_DEVICENAME := 0x20000007
RIDI_DEVICEINFO := 0x2000000b

; Register to receive raw input
OnMessage(0x00FF, RawInput_Message)  ; WM_INPUT

; Register raw input devices
RegisterRawInputDevices()

; F1 hotkey to display the current keyboard's HID
F1::
{
    MsgBox("Press any key to detect its device HID...")

    ; Wait for the next key press to get device info
    ih := InputHook("L1")
    ih.Start()
    ih.Wait()  ; Wait for input to complete
    key := ih.Input

    ; The RawInput_Message handler will capture the device info
    ; and store it in a global variable that we can display
    if (HasProp(g_InputDevice, "hid"))
        MsgBox("Last Key: " key "`n`nDevice Information:`n" DeviceInfoToString(g_InputDevice))
    else
        MsgBox("Could not detect device. Try pressing another key.")
}

; Function to register for raw input
RegisterRawInputDevices() {
    ; Create global storage for device information
    global g_InputDevice := {}

    ; Structure for registering raw input devices
    RAWINPUTDEVICE := Buffer(16)

    ; Register keyboard
    NumPut("UShort", 1, RAWINPUTDEVICE, 0)   ; usUsagePage = Generic Desktop Controls
    NumPut("UShort", 6, RAWINPUTDEVICE, 2)   ; usUsage = Keyboard
    NumPut("UInt", RIDEV_INPUTSINK, RAWINPUTDEVICE, 4)  ; dwFlags
    NumPut("UPtr", A_ScriptHwnd, RAWINPUTDEVICE, 8)     ; hwndTarget

    ; Register the device
    if (!DllCall("RegisterRawInputDevices", "Ptr", RAWINPUTDEVICE, "UInt", 1, "UInt", 16))
        MsgBox("Failed to register raw input devices. Error: " A_LastError)
}

; Message handler for WM_INPUT
RawInput_Message(wParam, lParam, msg, hwnd) {
    static deviceNameBuffer := Buffer(256)
    static deviceInfoBuffer := Buffer(32)

    ; Get the size of the RAWINPUT structure
    size := 0
    DllCall("GetRawInputData", "Ptr", lParam, "UInt", RID_INPUT, "Ptr", 0, "UInt*", &size, "UInt", 16)

    ; Create a buffer for the RAWINPUT structure
    rawInput := Buffer(size)

    ; Get the RAWINPUT data
    if (DllCall("GetRawInputData", "Ptr", lParam, "UInt", RID_INPUT, "Ptr", rawInput, "UInt*", &size, "UInt", 16) = -1)
        return

    ; Get device type (keyboard or mouse)
    deviceType := NumGet(rawInput, 0, "UInt")

    ; We're only interested in keyboard events
    if (deviceType != RIM_TYPEKEYBOARD)
        return

    ; Get the device handle
    deviceHandle := NumGet(rawInput, 8, "Ptr")

    ; Get the size needed for the device name
    nameSize := 256
    if (DllCall("GetRawInputDeviceInfo", "Ptr", deviceHandle, "UInt", RIDI_DEVICENAME, "Ptr", deviceNameBuffer, "UInt*", &
        nameSize) = -1)
        return

    ; Get the device name (which contains the HID)
    deviceName := StrGet(deviceNameBuffer)

    ; Get device info
    infoSize := 32
    if (DllCall("GetRawInputDeviceInfo", "Ptr", deviceHandle, "UInt", RIDI_DEVICEINFO, "Ptr", deviceInfoBuffer, "UInt*", &
        infoSize) = -1)
        return

    ; Parse device info
    global g_InputDevice := {}
    g_InputDevice.handle := deviceHandle
    g_InputDevice.name := deviceName
    g_InputDevice.type := (deviceType = RIM_TYPEKEYBOARD) ? "KEYBOARD" : "MOUSE"

    ; Extract the HID from the device name
    g_InputDevice.hid := ExtractHID(deviceName)
}

; Extract HID information from device name
ExtractHID(deviceName) {
    ; Device names typically follow this pattern:
    ; \\?\HID#VID_XXXX&PID_XXXX#X&XXXXXXXX#{GUID}

    ; Extract just the HID part
    if (RegExMatch(deviceName, "i)HID[^#]*#[^#]*", &match))
        return match[0]
    else
        return "Unknown HID format: " deviceName
}

; Convert device info to display string
DeviceInfoToString(device) {
    info := ""
    info .= "Type: " device.type "`n"
    info .= "Handle: " device.handle "`n"
    info .= "Name: " device.name "`n"
    info .= "HID: " device.hid
    return info
}
