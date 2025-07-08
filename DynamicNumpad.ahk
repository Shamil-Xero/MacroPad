#Requires AutoHotkey v2.0

class DynamicNumpad {
    settingsFile := "numpad_settings.ini"
    iniFile := ""
    mode := 1
    timeout := 5
    settings := Map()
    gui := ""
    buttons := Map()
    pictures := Map()
    buttonBackgrounds := Map()
    buttonImages := Map()
    fadeTimer := 0
    fadeInTimer := 0
    fadeOutTimer := 0
    isSelectingImage := false
    shouldFadeOut := false

    __New(iniFile := "", timeout := -1, mode := 1) {
        this.ClearTimers()
        this.mode := mode
        this.LoadSettings()
        if (iniFile != "") {
            this.iniFile := iniFile
        } else if (this.settings.Has("ImagesIniFile" this.mode)) {
            this.iniFile := this.settings["ImagesIniFile" this.mode]
        } else {
            this.iniFile := "numpad_images" this.mode ".ini"
        }
        this.timeout := (timeout != -1) ? timeout : this.settings["Timeout"]
        this.CreateGUI()
        this.CreateButtons()
        this.LoadImagesFromIni()
        this.ShowGUI()
    }

    LoadSettings() {
        this.settings := Map(
            "WindowX", 0, "WindowY", A_ScreenHeight - 500, "WindowWidth", 400, "WindowHeight", 500,
            "Transparency", 70, "BackgroundColor", "1a1a1a", "TitleBarColor", "2d2d2d", "ButtonColor", "2d2d2d",
            "ButtonBackgroundColor", "3d3d3d", "FontSize", 12, "FontName", "Arial", "ButtonSize", 80,
            "ImagesIniFile1", "numpad_images.ini", "ImagesIniFile2", "numpad_images2.ini",
            "ImagesIniFile3", "numpad_images3.ini", "ImagesIniFile4", "numpad_images4.ini", "Timeout", 5)
        if (!FileExist(this.settingsFile)) {
            try for k, v in this.settings
                IniWrite(v, this.settingsFile, "Settings", k)
        } else {
            try for k in this.settings {
                v := IniRead(this.settingsFile, "Settings", k)
                if (v != "ERROR")
                    this.settings[k] := IsNumber(v) ? Number(v) : v
            }
        }
    }

    CreateGUI() {
        this.gui := Gui("+AlwaysOnTop -Caption +ToolWindow -Border +E0x08000000")
        this.gui.BackColor := this.settings["BackgroundColor"]
        this.gui.SetFont("s" this.settings["FontSize"] " bold", this.settings["FontName"])
        this.gui.Add("Text", "x0 y0 w" this.settings["WindowWidth"] " h30 Background" this.settings["TitleBarColor"]).OnEvent(
            "Click", this.DragWindow.Bind(this))
        this.gui.Opt("+LastFound")
        WinSetTransparent(0)
    }

    DragWindow(thisGui, info) {
        if (info.MouseButton = "Left")
            PostMessage(0xA1, 2, 0, , "A")
    }

    ShowGUI() {
        x := this.settings["WindowX"]
        y := this.settings["WindowY"]
        this.gui.Show("x" x " y" y " w" this.settings["WindowWidth"] " h" this.settings["WindowHeight"] " Hide NA")
        this.FadeIn()
        if (this.timeout > 0) {
            this.shouldFadeOut := true
            this.fadeTimer := SetTimer(() => this.StartFadeOut(), -this.timeout * 1000)
        }
    }

    CreateButtons() {
        layout := [["Num`nLock", 0, 0], ["/", 0, 1], ["*", 0, 2], ["-", 0, 3], ["7", 1, 0], ["8", 1, 1], ["9", 1, 2], [
            "+", 1, 3, 2], ["4", 2, 0], ["5", 2, 1], ["6", 2, 2], ["1", 3, 0], ["2", 3, 1], ["3", 3, 2], ["Enter", 3, 3,
                2], ["0", 4, 0, 2], [".", 4, 2]]
        sp := 10
        w := this.settings["WindowWidth"]
        h := this.settings["WindowHeight"]
        bs := this.settings["ButtonSize"]
        bW := (w - sp * 5) / 4
        bH := (h - 30 - sp * 6) / 5
        scale := bs / 80
        bW *= scale
        bH *= scale
        for i, b in layout {
            text := b[1]
            row := b[2]
            col := b[3]
            rowspan := 1
            colspan := 1
            if (b.Length = 4) {
                if (row = 1 || row = 3)
                    rowspan := b[4]
                else
                    colspan := b[4]
            }
            x := col * (bW + sp) + sp
            y := row * (bH + sp) + sp + 30
            w2 := bW * colspan + sp * (colspan - 1)
            h2 := bH * rowspan + sp * (rowspan - 1)
            btn := this.gui.Add("Button", "x" x " y" y " w" w2 " h" h2, text)
            btn.OnEvent("Click", (btn, *) => this.SelectImageForButton(btn.Text))
            btn.BackColor := this.settings["ButtonColor"]
            btn.SetFont("s" this.settings["FontSize"] " bold", this.settings["FontName"])
            bg := this.gui.Add("Text", "x" x " y" y " w" w2 " h" h2 " Hidden Background" this.settings[
                "ButtonBackgroundColor"])
            pic := this.gui.Add("Picture", "x" x " y" y " w" w2 " h" h2 " Hidden")
            pic.OnEvent("Click", (pic, *) => this.SelectImageForButton(this.GetButtonTextFromPicture(pic)))
            this.buttons[text] := btn
            this.pictures[text] := pic
            this.buttonBackgrounds[text] := bg
        }
    }

    GetButtonTextFromPicture(pic) {
        for t, p in this.pictures {
            if (p = pic) {
                return t
            }
        }
        return ""
    }

    FadeIn(alpha := 0) {
        try {
            if (!IsObject(this.gui)) {
                return
            }
            if (!this.gui.Hwnd) {
                return
            }
            if (alpha < this.settings["Transparency"]) {
                alpha += 5
                this.gui.Opt("+LastFound")
                WinSetTransparent(alpha)
                this.fadeInTimer := SetTimer(ObjBindMethod(DynamicNumpad, "FadeInTimerCallback", this, alpha), -20)
            } else {
                this.gui.Opt("+LastFound")
                WinSetTransparent(this.settings["Transparency"])
                this.fadeInTimer := 0
            }
        } catch {
            return
        }
    }
    static FadeInTimerCallback(instance, alpha) {
        if IsObject(instance) {
            instance.FadeIn(alpha)
        }
    }

    StartFadeOut() {
        try {
            if (!IsObject(this.gui)) {
                return
            }
            if (!this.gui.Hwnd) {
                return
            }
            if (!this.isSelectingImage && this.shouldFadeOut) {
                this.FadeOut(this.settings["Transparency"])
            }
        } catch {
            return
        }
    }

    FadeOut(alpha) {
        try {
            if (!IsObject(this.gui)) {
                return
            }
            if (!this.gui.Hwnd) {
                return
            }
            if (this.isSelectingImage) {
                return
            }
            if (alpha > 0) {
                alpha -= 5
                this.gui.Opt("+LastFound")
                WinSetTransparent(alpha)
                this.fadeOutTimer := SetTimer(ObjBindMethod(DynamicNumpad, "FadeOutTimerCallback", this, alpha), -20)
            } else {
                this.ClearTimers()
                this.gui.Destroy()
                this.gui := ""
            }
        } catch {
            return
        }
    }
    static FadeOutTimerCallback(instance, alpha) {
        if IsObject(instance) {
            instance.FadeOut(alpha)
        }
    }

    SelectImageForButton(buttonText) {
        if (this.isSelectingImage) {
            return
        }
        this.isSelectingImage := true
        this.shouldFadeOut := false
        this.ClearTimers()
        selectedFile := FileSelect(1, , "Select image for " buttonText, "Image Files (*.png; *.jpg; *.jpeg; *.gif)")
        if (selectedFile) {
            try {
                this.SaveImageToIni(buttonText, selectedFile)
                this.buttonImages[buttonText] := selectedFile
                this.buttons[buttonText].Text := ""
                this.buttonBackgrounds[buttonText].Visible := true
                this.pictures[buttonText].Value := selectedFile
                this.pictures[buttonText].Visible := true
                this.buttons[buttonText].Visible := false
            } catch as e {
                MsgBox("Error loading image: " e.Message)
            }
        }
        this.isSelectingImage := false
        this.shouldFadeOut := true
        if (this.timeout > 0) {
            this.fadeTimer := SetTimer(() => this.StartFadeOut(), -this.timeout * 1000)
        }
    }

    SaveImageToIni(buttonName, imagePath) {
        IniWrite(imagePath, this.iniFile, "Images", buttonName = "Num`nLock" ? "NumLock" : buttonName)
    }

    LoadImagesFromIni() {
        if (!FileExist(this.iniFile)) {
            return
        }
        try {
            iniContent := IniRead(this.iniFile, "Images")
            if (!iniContent) {
                return
            }
            for line in StrSplit(iniContent, "`n") {
                if (!line) {
                    continue
                }
                parts := StrSplit(line, "=")
                if (parts.Length != 2) {
                    continue
                }
                iniKey := parts[1]
                imagePath := parts[2]
                buttonName := iniKey = "NumLock" ? "Num`nLock" : iniKey
                if (this.buttons.Has(buttonName) && FileExist(imagePath)) {
                    this.buttonImages[buttonName] := imagePath
                    this.buttons[buttonName].Text := ""
                    this.buttonBackgrounds[buttonName].Visible := true
                    this.pictures[buttonName].Value := imagePath
                    this.pictures[buttonName].Visible := true
                    this.buttons[buttonName].Visible := false
                }
            }
        } catch as e {
            MsgBox("Error loading INI file: " e.Message)
        }
    }

    ClearTimers() {
        if (this.fadeTimer) {
            SetTimer(this.fadeTimer, 0)
            this.fadeTimer := 0
        }
        if (this.fadeInTimer) {
            SetTimer(this.fadeInTimer, 0)
            this.fadeInTimer := 0
        }
        if (this.fadeOutTimer) {
            SetTimer(this.fadeOutTimer, 0)
            this.fadeOutTimer := 0
        }
    }
}

args := A_Args
iniFile := ""
timeout := -1
mode := 1
for i, arg in args {
    if (arg = "--ini" && args.Has(i + 1)) {
        iniFile := args[i + 1]
    } else if (arg = "--timeout" && args.Has(i + 1)) {
        timeout := Integer(args[i + 1])
    } else if (arg = "--mode" && args.Has(i + 1)) {
        mode := Integer(args[i + 1])
    }
}
numpad := DynamicNumpad(iniFile, timeout, mode)