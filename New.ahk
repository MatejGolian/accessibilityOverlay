﻿#Requires AutoHotkey v2.0

Class AccessibilityOverlay {

ChildControls := Array()
ControlID := 0
ControlType := "AccessibilityOverlay"
ControlTypeLabel := "overlay"
CurrentControlID := 0
DefaultLabel := ""
FocusableControlIDs := Array()
Label := ""
PreviousControlID := 0
SuperordinateControlID := 0
Static AllControls := Array()
Static CurrentControlID := 0
Static JAWS := False
Static PreviousControlID := 0
Static SAPI := False
Static TotalNumberOfControls := 0

Static __New() {
Try
JAWS := ComObject("FreedomSci.JawsApi")
Catch
JAWS := False
AccessibilityOverlay.JAWS := JAWS
Try
SAPI := ComObject("SAPI.SpVoice")
Catch
SAPI := False
AccessibilityOverlay.SAPI := SAPI
}

Static OCR(X1Coordinate, Y1Coordinate, X2Coordinate, Y2Coordinate, OCRLanguage := "", OCRScale := 1) {
If IsSet(OCR) {
AvailableLanguages := OCR.GetAvailableLanguages()
FirstAvailableLanguage := False
PreferredLanguage := False
Loop Parse, AvailableLanguages, "`n" {
If A_Index = 1 And A_LoopField != ""
FirstAvailableLanguage := A_LoopField
If A_LoopField = OCRLanguage And OCRLanguage != "" {
PreferredLanguage := OCRLanguage
Break
}
}
If PreferredLanguage = False And FirstAvailableLanguage != False {
OCRResult := OCR.FromWindow("A", FirstAvailableLanguage, OCRScale)
OCRResult := OCRResult.Crop(X1Coordinate, Y1Coordinate, X2Coordinate, Y2Coordinate)
Return OCRResult.Text
}
Else If PreferredLanguage = OCRLanguage{
OCRResult := OCR.FromWindow("A", PreferredLanguage, OCRScale)
OCRResult := OCRResult.Crop(X1Coordinate, Y1Coordinate, X2Coordinate, Y2Coordinate)
Return OCRResult.Text
}
Else {
Return ""
}
}
Return ""
}

Static Speak(Message) {
If (AccessibilityOverlay.JAWS != False And ProcessExist("jfw.exe")) Or (FileExist("NvdaControllerClient" . A_PtrSize * 8 . ".dll") And !DllCall("NvdaControllerClient" . A_PtrSize * 8 . ".dll\nvdaController_testIfRunning")) {
If AccessibilityOverlay.JAWS != False And ProcessExist("jfw.exe") {
AccessibilityOverlay.JAWS.SayString(Message)
}
If FileExist("NvdaControllerClient" . A_PtrSize * 8 . ".dll") And !DllCall("NvdaControllerClient" . A_PtrSize * 8 . ".dll\nvdaController_testIfRunning") {
DllCall("NvdaControllerClient" . A_PtrSize * 8 . ".dll\nvdaController_cancelSpeech")
DllCall("NvdaControllerClient" . A_PtrSize * 8 . ".dll\nvdaController_speakText", "Wstr", Message)
}
}
Else {
If AccessibilityOverlay.SAPI != False {
AccessibilityOverlay.SAPI.Speak("", 0x1|0x2)
AccessibilityOverlay.SAPI.Speak(Message, 0x1)
}
}
}

Static StopSpeech() {
If (AccessibilityOverlay.JAWS != False Or !ProcessExist("jfw.exe")) And (!FileExist("NvdaControllerClient" . A_PtrSize * 8 . ".dll") Or DllCall("NvdaControllerClient" . A_PtrSize * 8 . ".dll\nvdaController_testIfRunning"))
If AccessibilityOverlay.SAPI != False
AccessibilityOverlay.SAPI.Speak("", 0x1|0x2)
}

}

Class FocusableControl {

ControlID := 0
ControlType := "FocusableControl"
ControlTypeLabel := ""
DefaultLabel := ""
DefaultValue := ""
Focused := 1
FocusFunctions := Array()
HotkeyCommand := ""
HotkeyFunctions := Array()
HotkeyLabel := ""
Label := ""
state := 1
States := Map()
SuperordinateControlID := 0
Value := ""

__New(Label := "", FocusFunctions := "") {
This.Label := Label
If FocusFunctions != "" {
If Not FocusFunctions Is Array
FocusFunctions := Array(FocusFunctions)
For FocusFunction In FocusFunctions
If FocusFunction Is Object And FocusFunction.HasMethod("Call")
This.FocusFunctions.Push(FocusFunction)
}
AccessibilityOverlay.TotalNumberOfControls++
This.ControlID := AccessibilityOverlay.TotalNumberOfControls
AccessibilityOverlay.AllControls.Push(This)
}

CheckFocus() {
Return This.Focused
}

CheckState() {
Return This.state
}

Focus(Speak := True) {
If This.ControlID != AccessibilityOverlay.CurrentControlID
For FocusFunction In This.FocusFunctions
FocusFunction.Call(This)
If This.CheckFocus() {
If Speak= True
This.SpeakOnFocus()
If This.HasMethod("ExecuteOnFocus")
This.ExecuteOnFocus()
}
}

GetValue() {
Return This.Value
}

ReportValue() {
AccessibilityOverlay.Speak(This.GetValue())
}

SetHotkey(HotkeyCommand, HotkeyLabel := "", HotkeyFunctions := "") {
This.HotkeyCommand := HotkeyCommand
This.HotkeyLabel := HotkeyLabel
If HotkeyFunctions != "" {
If Not HotkeyFunctions Is Array
HotkeyFunctions := Array(HotkeyFunctions)
For HotkeyFunction In HotkeyFunctions
If HotkeyFunction Is Object And HotkeyFunction.HasMethod("Call")
This.HotkeyFunctions.Push(HotkeyFunction)
}
}

SetValue(Value) {
This.Value := Value
}

SpeakOnFocus() {
CheckResult := This.CheckState()
LabelString := This.Label
If LabelString = ""
LabelString := This.DefaultLabel
ValueString := This.GetValue()
If ValueString = ""
ValueString := This.DefaultValue
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID
AccessibilityOverlay.Speak(LabelString . " " . This.ControlTypeLabel . " " . ValueString . " " . StateString . " " . This.HotkeyLabel)
}

}

Class ActivatableControl Extends FocusableControl {

ActivationFunctions := Array()
ControlType := "ActivatableControl"

__New(Label := "", FocusFunctions := "", ActivationFunctions := "") {
Super.__New(Label, FocusFunctions)
If ActivationFunctions != "" {
If Not ActivationFunctions Is Array
ActivationFunctions := Array(ActivationFunctions)
For ActivationFunction In ActivationFunctions
If ActivationFunction Is Object And ActivationFunction.HasMethod("Call")
This.ActivationFunctions.Push(ActivationFunction)
}
}

Activate(Speak := True) {
This.Focus()
If This.Focused {
For ActivationFunction In This.ActivationFunctions
ActivationFunction.Call(This)
If This.CheckFocus() {
If Speak
This.SpeakOnActivation()
If This.HasMethod("ExecuteOnActivation")
This.ExecuteOnActivation()
}
}
}

SpeakOnActivation() {
CheckResult := This.CheckState()
LabelString := This.Label
If LabelString = ""
LabelString := This.DefaultLabel
ValueString := This.GetValue()
If ValueString = ""
ValueString := This.DefaultValue
StateString := ""
If This.states.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID = AccessibilityOverlay.CurrentControlID And This.ControlID != AccessibilityOverlay.PreviousControlID
AccessibilityOverlay.Speak(LabelString . " " . This.ControlTypeLabel . " " . ValueString . " " . StateString)
Else
If This.ControlID = AccessibilityOverlay.CurrentControlID And This.ControlID = AccessibilityOverlay.PreviousControlID And This.states.Length > 1
AccessibilityOverlay.Speak(StateString)
}

}

Class Button Extends ActivatableControl {

ControlType := "Button"
ControlTypeLabel := "button"
DefaultLabel := "unlabelled"

__New(Label, FocusFunctions := "", ActivationFunctions := "") {
Super.__New(Label, FocusFunctions, ActivationFunctions)
}

}

Class Checkbox Extends ActivatableControl {

ControlType := "Checkbox"
ControlTypeLabel := "checkbox"
DefaultLabel := "unlabelled"
States := Map("-1", "unknown state", "0", "not checked", "1", "checked")

__New(Label, FocusFunctions := "", ActivationFunctions := "") {
Super.__New(Label, FocusFunctions, ActivationFunctions)
}

}

Class ComboBox Extends FocusableControl {

ChangeFunctions := Array()
ControlType := "ComboBox"
ControlTypeLabel := "combo box"
CurrentOption := 1
Options := Array()

__New(Label, FocusFunctions := "", ChangeFunctions := "") {
Super.__New(Label, FocusFunctions)
If ChangeFunctions != "" {
If Not ChangeFunctions Is Array
ChangeFunctions := Array(ChangeFunctions)
For ChangeFunction In ChangeFunctions
If ChangeFunction Is Object And ChangeFunction.HasMethod("Call")
This.ChangeFunctions.Push(ChangeFunction)
}
}

SelectNextOption() {
If This.Options.Length > 0
If This.CurrentOption < This.Options.Length {
This.CurrentOption++
This.Value := This.Options[This.CurrentOption]
}
For ChangeFunction In This.ChangeFunctions
ChangeFunction.Call(This)
}

SelectOption(Option) {
If Not Option Is Integer Or Option < 1 Or Option > This.Options.Length
This.CurrentOption := 1
Else
This.CurrentOption := Option
If This.Options.Has(Option)
This.Value := This.Options[Option]
}

SelectPreviousOption() {
If This.Options.Length > 0
If This.CurrentOption > 1 {
This.CurrentOption--
This.Value := This.Options[This.CurrentOption]
}
For ChangeFunction In This.ChangeFunctions
ChangeFunction.Call(This)
}

SetOptions(Options, DefaultOption := 1) {
If Not Options Is Array
Options := Array(Options)
For Option In Options
If Not Option Is Object
This.Options.Push(Option)
If Not DefaultOption Is Integer Or DefaultOption < 1 Or DefaultOption > This.Options.Length
This.CurrentOption := 1
Else
This.CurrentOption := DefaultOption
}

}

Class Edit Extends FocusableControl {

ControlType := "Edit"
ControlTypeLabel := "edit"
DefaultLabel := "unlabelled"
DefaultValue := "blank"

__New(Label, FocusFunctions := "") {
Super.__New(Label, FocusFunctions)
}

}

Class Tab Extends AccessibilityOverlay {

ControlType := "Tab"
ControlTypeLabel := "tab"
DefaultLabel := "Unlabelled"
Focused := 1
FocusFunctions := Array()
HotkeyCommand := ""
HotkeyFunctions := Array()
HotkeyLabel := ""
state := 1
States := Map("0", "not found", "1", "selected")

__New(Label, FocusFunctions := "") {
Super.__New(Label)
If FocusFunctions != "" {
If Not FocusFunctions Is Array
FocusFunctions := Array(FocusFunctions)
For FocusFunction In FocusFunctions
If FocusFunction Is Object And FocusFunction.HasMethod("Call")
This.FocusFunctions.Push(FocusFunction)
}
}

CheckFocus() {
Return This.Focused
}

CheckState() {
Return This.state
}

Focus(Speak := True) {
If This.ControlID != AccessibilityOverlay.CurrentControlID
For FocusFunction In This.FocusFunctions
FocusFunction.Call(This)
If This.CheckFocus() {
If Speak
This.SpeakOnFocus()
If This.HasMethod("ExecuteOnFocus")
This.ExecuteOnFocus()
}
}

SetHotkey(HotkeyCommand, HotkeyLabel := "", HotkeyFunctions := "") {
This.HotkeyCommand := HotkeyCommand
This.HotkeyLabel := HotkeyLabel
If HotkeyFunctions != "" {
If Not HotkeyFunctions Is Array
HotkeyFunctions := Array(HotkeyFunctions)
For HotkeyFunction In HotkeyFunctions
If HotkeyFunction Is Object And HotkeyFunction.HasMethod("Call")
This.HotkeyFunctions.Push(HotkeyFunction)
}
}

SpeakOnFocus() {
CheckResult := This.CheckState()
LabelString := This.Label
If LabelString = ""
LabelString := This.DefaultLabel
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID
AccessibilityOverlay.Speak(LabelString . " " . This.ControlTypeLabel . " " . StateString . " " . This.HotkeyLabel)
}

}

Class CustomButton Extends Button {
}

Class CustomCheckbox Extends Checkbox {

CheckStateFunction := ""

__New(Label, CheckStateFunction := "", FocusFunctions := "", ActivationFunctions := "") {
Super.__New(Label, FocusFunctions, ActivationFunctions)
If CheckStateFunction Is Object And CheckStateFunction.HasMethod("Call")
This.CheckStateFunction := CheckStateFunction
}

CheckState() {
If This.CheckStateFunction Is Object And This.CheckStateFunction.HasMethod("Call")
This.state := This.CheckStateFunction.Call(This)
Return This.state
}

}

Class CustomComboBox Extends ComboBox {
}

Class CustomControl Extends ActivatableControl {

ControlType := "Custom"

__New(FocusFunctions := "", ActivationFunctions := "") {
Super.__New("", FocusFunctions, ActivationFunctions)
}

}

Class CustomEdit Extends Edit {
}

Class CustomTab Extends Tab {
}

Class CustomToggleButton Extends ToggleButton {

CheckStateFunction := ""

__New(Label, CheckStateFunction := "", FocusFunctions := "", ActivationFunctions := "") {
Super.__New(Label, FocusFunctions, ActivationFunctions)
If CheckStateFunction Is Object And CheckStateFunction.HasMethod("Call")
This.CheckStateFunction := CheckStateFunction
}

CheckState() {
If This.CheckStateFunction Is Object And This.CheckStateFunction.HasMethod("Call")
This.state := This.CheckStateFunction.Call(This)
Return This.state
}

}

Class HotspotButton Extends Button {

XCoordinate := 0
YCoordinate := 0

__New(Label, XCoordinate, YCoordinate, FocusFunctions := "", ActivationFunctions := "") {
Super.__New(Label, FocusFunctions, ActivationFunctions)
This.XCoordinate := XCoordinate
This.YCoordinate := YCoordinate
}

ExecuteOnActivation() {
Click This.XCoordinate, This.YCoordinate
}

ExecuteOnFocus() {
MouseMove This.XCoordinate, This.YCoordinate
}

}

Class HotspotCheckbox Extends Checkbox {

CheckedColors := Array()
UncheckedColors := Array()
XCoordinate := 0
YCoordinate := 0

__New(Label, XCoordinate, YCoordinate, CheckedColors, UncheckedColors, FocusFunctions := "", ActivationFunctions := "") {
Super.__New(Label, FocusFunctions, ActivationFunctions)
If CheckedColors != "" {
If Not CheckedColors Is Array
CheckedColors := Array(CheckedColors)
For CheckedColor In CheckedColors
If Not CheckedColor Is Object
This.CheckedColors.Push(CheckedColor)
}
If UncheckedColors != "" {
If Not UncheckedColors Is Array
UncheckedColors := Array(UncheckedColors)
For UncheckedColor In UncheckedColors
If Not UncheckedColor Is Object
This.UncheckedColors.Push(UncheckedColor)
}
This.XCoordinate := XCoordinate
This.YCoordinate := YCoordinate
}

CheckState() {
Sleep 100
CurrentColor := PixelGetColor(This.XCoordinate, This.YCoordinate)
For CheckedColor In This.CheckedColors
If CurrentColor = CheckedColor {
This.state := 1
Return 1
}
For UncheckedColor In This.UncheckedColors
If CurrentColor = UncheckedColor {
This.state := 0
Return 0
}
This.state := -1
Return -1
}

ExecuteOnActivation() {
Click This.XCoordinate, This.YCoordinate
}

ExecuteOnFocus() {
MouseMove This.XCoordinate, This.YCoordinate
}

}

Class HotspotComboBox Extends ComboBox {

XCoordinate := 0
YCoordinate := 0

__New(Label, XCoordinate, YCoordinate, FocusFunctions := "", ChangeFunctions := "") {
Super.__New(Label, FocusFunctions, ChangeFunctions)
This.XCoordinate := XCoordinate
This.YCoordinate := YCoordinate
}

ExecuteOnFocus() {
Click This.XCoordinate, This.YCoordinate
}

}

Class HotspotEdit Extends Edit {

XCoordinate := 0
YCoordinate := 0

__New(Label, XCoordinate, YCoordinate, FocusFunctions := "") {
Super.__New(Label, FocusFunctions)
This.XCoordinate := XCoordinate
This.YCoordinate := YCoordinate
}

ExecuteOnFocus() {
Click This.XCoordinate, This.YCoordinate
}

}

Class HotspotTab Extends Tab {

XCoordinate := 0
YCoordinate := 0

__New(Label, XCoordinate, YCoordinate, FocusFunctions := "") {
Super.__New(Label, FocusFunctions)
This.XCoordinate := XCoordinate
This.YCoordinate := YCoordinate
}

ExecuteOnFocus() {
Click This.XCoordinate, This.YCoordinate
}

}

Class HotspotToggleButton Extends ToggleButton {

CheckedColors := Array()
UncheckedColors := Array()
XCoordinate := 0
YCoordinate := 0

__New(Label, XCoordinate, YCoordinate, CheckedColors, UncheckedColors, FocusFunctions := "", ActivationFunctions := "") {
Super.__New(Label, FocusFunctions, ActivationFunctions)
If CheckedColors != "" {
If Not CheckedColors Is Array
CheckedColors := Array(CheckedColors)
For CheckedColor In CheckedColors
If Not CheckedColor Is Object
This.CheckedColors.Push(CheckedColor)
}
If UncheckedColors != "" {
If Not UncheckedColors Is Array
UncheckedColors := Array(UncheckedColors)
For UncheckedColor In UncheckedColors
If Not UncheckedColor Is Object
This.UncheckedColors.Push(UncheckedColor)
}
This.XCoordinate := XCoordinate
This.YCoordinate := YCoordinate
}

CheckState() {
Sleep 100
CurrentColor := PixelGetColor(This.XCoordinate, This.YCoordinate)
For CheckedColor In This.CheckedColors
If CurrentColor = CheckedColor {
This.state := 1
Return 1
}
For UncheckedColor In This.UncheckedColors
If CurrentColor = UncheckedColor {
This.state := 0
Return 0
}
This.state := -1
Return -1
}

ExecuteOnActivation() {
Click This.XCoordinate, This.YCoordinate
}

ExecuteOnFocus() {
MouseMove This.XCoordinate, This.YCoordinate
}

}

Class OCRButton Extends Button {

DefaultLabel := ""
OCRLanguage := ""
OCRScale := 1
X1Coordinate := 0
Y1Coordinate := 0
X2Coordinate := 0
Y2Coordinate := 0

__New(X1Coordinate, Y1Coordinate, X2Coordinate, Y2Coordinate, OCRLanguage := "", OCRScale := 1, FocusFunctions := "", ActivationFunctions := "") {
Super.__New("", FocusFunctions, ActivationFunctions)
This.OCRLanguage := OCRLanguage
This.OCRScale := OCRScale
This.X1Coordinate := X1Coordinate
This.Y1Coordinate := Y1Coordinate
This.X2Coordinate := X2Coordinate
This.Y2Coordinate := Y2Coordinate
}

ExecuteOnActivation() {
XCoordinate := This.X1Coordinate + Floor((This.X2Coordinate - This.X1Coordinate)/2)
YCoordinate := This.Y1Coordinate + Floor((This.Y2Coordinate - This.Y1Coordinate)/2)
Click XCoordinate, YCoordinate
}

ExecuteOnFocus() {
XCoordinate := This.X1Coordinate + Floor((This.X2Coordinate - This.X1Coordinate)/2)
YCoordinate := This.Y1Coordinate + Floor((This.Y2Coordinate - This.Y1Coordinate)/2)
MouseMove XCoordinate, YCoordinate
}

SpeakOnActivation() {
CheckResult := This.CheckState()
LabelString := AccessibilityOverlay.OCR(This.X1Coordinate, This.Y1Coordinate, This.X2Coordinate, This.Y2Coordinate, This.OCRLanguage, This.OCRScale)
This.Label := LabelString
If LabelString = ""
LabelString := This.DefaultLabel
StateString := ""
If This.states.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID = AccessibilityOverlay.CurrentControlID And This.ControlID != AccessibilityOverlay.PreviousControlID
AccessibilityOverlay.Speak(LabelString . " " . This.ControlTypeLabel . " " . StateString)
Else
If This.ControlID = AccessibilityOverlay.CurrentControlID And This.ControlID = AccessibilityOverlay.PreviousControlID And This.states.Length > 1
AccessibilityOverlay.Speak(StateString)
}

SpeakOnFocus() {
CheckResult := This.CheckState()
LabelString := AccessibilityOverlay.OCR(This.X1Coordinate, This.Y1Coordinate, This.X2Coordinate, This.Y2Coordinate, This.OCRLanguage, This.OCRScale)
If LabelString = ""
LabelString := This.DefaultLabel
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID
AccessibilityOverlay.Speak(LabelString . " " . This.ControlTypeLabel . " " . StateString . " " . This.HotkeyLabel)
}

}

Class OCRComboBox Extends ComboBox {

OCRLanguage := ""
OCRScale := 1
X1Coordinate := 0
Y1Coordinate := 0
X2Coordinate := 0
Y2Coordinate := 0

__New(Label, X1Coordinate, Y1Coordinate, X2Coordinate, Y2Coordinate, OCRLanguage := "", OCRScale := 1, FocusFunctions := "", ChangeFunctions := "") {
Super.__New(Label, FocusFunctions, ChangeFunctions)
This.OCRLanguage := OCRLanguage
This.OCRScale := OCRScale
This.X1Coordinate := X1Coordinate
This.Y1Coordinate := Y1Coordinate
This.X2Coordinate := X2Coordinate
This.Y2Coordinate := Y2Coordinate
}

ExecuteOnFocus() {
XCoordinate := This.X1Coordinate + Floor((This.X2Coordinate - This.X1Coordinate)/2)
YCoordinate := This.Y1Coordinate + Floor((This.Y2Coordinate - This.Y1Coordinate)/2)
Click XCoordinate, YCoordinate
}

GetValue() {
This.Value := AccessibilityOverlay.OCR(This.X1Coordinate, This.Y1Coordinate, This.X2Coordinate, This.Y2Coordinate, This.OCRLanguage, This.OCRScale)
Return This.Value
}

SpeakOnFocus() {
CheckResult := This.CheckState()
LabelString := This.Label
If LabelString = ""
LabelString := This.DefaultLabel
ValueString := This.GetValue()
If ValueString = ""
ValueString := This.DefaultValue
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID
AccessibilityOverlay.Speak(LabelString . " " . This.ControlTypeLabel . " " . ValueString . " " . StateString . " " . This.HotkeyLabel)
}

}

Class OCREdit Extends Edit {

OCRLanguage := ""
OCRScale := 1
X1Coordinate := 0
Y1Coordinate := 0
X2Coordinate := 0
Y2Coordinate := 0

__New(Label, X1Coordinate, Y1Coordinate, X2Coordinate, Y2Coordinate, OCRLanguage := "", OCRScale := 1, FocusFunctions := "") {
Super.__New(Label, FocusFunctions)
This.OCRLanguage := OCRLanguage
This.OCRScale := OCRScale
This.X1Coordinate := X1Coordinate
This.Y1Coordinate := Y1Coordinate
This.X2Coordinate := X2Coordinate
This.Y2Coordinate := Y2Coordinate
}

ExecuteOnFocus() {
XCoordinate := This.X1Coordinate + Floor((This.X2Coordinate - This.X1Coordinate)/2)
YCoordinate := This.Y1Coordinate + Floor((This.Y2Coordinate - This.Y1Coordinate)/2)
Click XCoordinate, YCoordinate
}

GetValue() {
This.Value := AccessibilityOverlay.OCR(This.X1Coordinate, This.Y1Coordinate, This.X2Coordinate, This.Y2Coordinate, This.OCRLanguage, This.OCRScale)
Return This.Value
}

SpeakOnFocus() {
CheckResult := This.CheckState()
LabelString := This.Label
If LabelString = ""
LabelString := This.DefaultLabel
ValueString := This.GetValue()
If ValueString = ""
ValueString := This.DefaultValue
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID
AccessibilityOverlay.Speak(LabelString . " " . This.ControlTypeLabel . " " . ValueString . " " . StateString . " " . This.HotkeyLabel)
}

}

Class OCRTab Extends Tab {

DefaultLabel := ""
OCRLanguage := ""
OCRScale := 1
X1Coordinate := 0
Y1Coordinate := 0
X2Coordinate := 0
Y2Coordinate := 0

__New(X1Coordinate, Y1Coordinate, X2Coordinate, Y2Coordinate, OCRLanguage := "", OCRScale := 1, FocusFunctions := "") {
Super.__New("", FocusFunctions)
This.OCRLanguage := OCRLanguage
This.OCRScale := OCRScale
This.X1Coordinate := X1Coordinate
This.Y1Coordinate := Y1Coordinate
This.X2Coordinate := X2Coordinate
This.Y2Coordinate := Y2Coordinate
}

ExecuteOnFocus() {
XCoordinate := This.X1Coordinate + Floor((This.X2Coordinate - This.X1Coordinate)/2)
YCoordinate := This.Y1Coordinate + Floor((This.Y2Coordinate - This.Y1Coordinate)/2)
Click XCoordinate, YCoordinate
}

SpeakOnFocus() {
CheckResult := This.CheckState()
LabelString := AccessibilityOverlay.OCR(This.X1Coordinate, This.Y1Coordinate, This.X2Coordinate, This.Y2Coordinate, This.OCRLanguage, This.OCRScale)
This.Label := LabelString
If LabelString = ""
LabelString := This.DefaultLabel
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID
AccessibilityOverlay.Speak(LabelString . " " . This.ControlTypeLabel . " " . StateString . " " . This.HotkeyLabel)
}

}

Class OCRText Extends FocusableControl {

ControlType := "Text"
DefaultLabel := ""
OCRLanguage := ""
OCRScale := 1
X1Coordinate := 0
Y1Coordinate := 0
X2Coordinate := 0
Y2Coordinate := 0

__New(X1Coordinate, Y1Coordinate, X2Coordinate, Y2Coordinate, OCRLanguage := "", OCRScale := 1, FocusFunctions := "") {
Super.__New("", FocusFunctions)
This.OCRLanguage := OCRLanguage
This.OCRScale := OCRScale
This.X1Coordinate := X1Coordinate
This.Y1Coordinate := Y1Coordinate
This.X2Coordinate := X2Coordinate
This.Y2Coordinate := Y2Coordinate
}

SpeakOnFocus() {
CheckResult := This.CheckState()
LabelString := AccessibilityOverlay.OCR(This.X1Coordinate, This.Y1Coordinate, This.X2Coordinate, This.Y2Coordinate, This.OCRLanguage, This.OCRScale)
This.Label := LabelString
If LabelString = ""
LabelString := This.DefaultLabel
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID
AccessibilityOverlay.Speak(LabelString . " " . StateString . " " . This.HotkeyLabel)
}

}

Class StaticText Extends FocusableControl {

ControlType := "Text"

SpeakOnFocus() {
CheckResult := This.CheckState()
LabelString := This.Label
If LabelString = ""
LabelString := This.DefaultLabel
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID
AccessibilityOverlay.Speak(LabelString . " " . StateString . " " . This.HotkeyLabel)
}

}

Class ToggleButton Extends Button {

States := Map("-1", "unknown state", "0", "off", "1", "on")

}
