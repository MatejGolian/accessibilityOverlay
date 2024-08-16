#Requires AutoHotkey v2.0

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
Static LastMessage := ""
Static PreviousControlID := 0
Static SAPI := False
Static TotalNumberOfControls := 0

__New(Label := "") {
This.Label := Label
AccessibilityOverlay.TotalNumberOfControls++
This.ControlID := AccessibilityOverlay.TotalNumberOfControls
AccessibilityOverlay.AllControls.Push(This)
}

__Call(Value, Properties) {
If SubStr(Value, 1, 3) == "Add" And IsSet(%SubStr(Value, 4)%){
Control := %SubStr(Value, 4)%.Call(Properties*)
Return This.AddControl(Control)
}
Return False
}

ActivateControl(ControlID) {
If This.ChildControls.Length > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(ControlID)
If Found > 0 {
CurrentControl := AccessibilityOverlay.GetControl(ControlID)
If CurrentControl.HasMethod("Focus") And ControlID != This.CurrentControlID {
CurrentControl.Focus()
This.SetCurrentControlID(ControlID)
}
If CurrentControl.HasMethod("Activate") {
CurrentControl.Activate()
This.SetCurrentControlID(ControlID)
Return 1
}
}
}
Return 0
}

ActivateCurrentControl() {
If This.ChildControls.Length > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found > 0 {
CurrentControl := AccessibilityOverlay.GetControl(This.CurrentControlID)
If CurrentControl.HasMethod("Activate")
CurrentControl.Activate()
Return 1
}
}
Return 0
}

AddControl(Control) {
Control.SuperordinateControlID := This.ControlID
This.ChildControls.Push(Control)
This.FocusableControlIDs := This.GetFocusableControlIDs()
Return This.ChildControls[This.ChildControls.Length]
}

AddControlAt(Index, Control) {
If Index <= 0 Or Index > This.ChildControls.Length
Index := This.ChildControls.Length + 1
Control.SuperordinateControlID := This.ControlID
This.ChildControls.InsertAt(Index, Control)
This.FocusableControlIDs := This.GetFocusableControlIDs()
Return This.ChildControls[Index]
}

Clone() {
Clone := Class()
Clone.Base := This.Base
Clone.ChildControls := Array()
Clone.CurrentControlID := 0
For PropertyName, PropertyValue In This.OwnProps()
If PropertyName != "ChildControls" And PropertyName != "ControlID" And PropertyName != "CurrentControlID" And PropertyName != "SuperordinateControlID"
Clone.%PropertyName% := PropertyValue
For CurrentControl In This.ChildControls
Switch(CurrentControl.__Class) {
Case "AccessibilityOverlay":
Clone.AddControl(CurrentControl.Clone())
Case "TabControl":
ClonedControl := TabControl()
For CurrentTab In CurrentControl.Tabs
ClonedControl.AddTabs(CurrentTab.Clone())
For PropertyName, PropertyValue In CurrentControl.OwnProps()
If !ClonedControl.HasProp(PropertyName)
ClonedControl.%PropertyName% := PropertyValue
Else
If PropertyName != "ControlID"And PropertyName != "CurrentTab" And PropertyName != "SuperordinateControlID" And PropertyName != "Tabs"
If ClonedControl.%PropertyName% != PropertyValue
ClonedControl.%PropertyName% := PropertyValue
Clone.AddControl(ClonedControl)
Default:
ClonedControl := Class()
ClonedControl.Base := CurrentControl.Base
For PropertyName, PropertyValue In CurrentControl.OwnProps()
If PropertyName != "ControlID" And PropertyName != "SuperordinateControlID"
ClonedControl.%PropertyName% := PropertyValue
Clone.AddControl(ClonedControl)
}
Return Clone
}

DecreaseSlider() {
If This.ChildControls.Length > 0 And This.CurrentControlID > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found > 0 {
CurrentControl := AccessibilityOverlay.GetControl(This.FocusableControlIDs[Found])
If CurrentControl Is GraphicalSlider {
CurrentControl.Decrease()
Return 1
}
}
}
Return 0
}

FindFocusableControlID(ControlID) {
FocusableControlIDs := This.GetFocusableControlIDs()
If FocusableControlIDs.Length > 0
For Index, Value In FocusableControlIDs
If Value = ControlID
Return Index
Return 0
}

Focus(ControlID := 0) {
If This.ChildControls.Length > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found = 0
This.CurrentControlID := This.FocusableControlIDs[1]
This.SetCurrentControlID(This.CurrentControlID)
CurrentControl := AccessibilityOverlay.GetControl(This.CurrentControlID)
If CurrentControl.HasMethod("Focus") {
CurrentControl.Focus()
Return 1
}
}
Return 0
}

FocusControl(ControlID) {
If This.ChildControls.Length > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(ControlID)
If Found > 0 {
CurrentControl := AccessibilityOverlay.GetControl(ControlID)
If CurrentControl.HasMethod("Focus")
If ControlID != This.CurrentControlID {
CurrentControl.Focus()
This.SetCurrentControlID(ControlID)
}
Else {
CurrentControl.Focus(ControlID)
}
Return 1
}
}
Return 0
}

FocusCurrentControl() {
If This.ChildControls.Length > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found > 0 {
CurrentControl := AccessibilityOverlay.GetControl(This.CurrentControlID)
If CurrentControl.HasMethod("Focus")
CurrentControl.Focus()
Return 1
}
}
Return 0
}

FocusNextControl() {
If This.ChildControls.Length > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found = 0 Or Found = This.FocusableControlIDs.Length
This.CurrentControlID := This.FocusableControlIDs[1]
Else
This.CurrentControlID := This.FocusableControlIDs[Found + 1]
This.SetCurrentControlID(This.CurrentControlID)
CurrentControl := AccessibilityOverlay.GetControl(This.CurrentControlID)
If CurrentControl.HasMethod("Focus") {
CurrentControl.Focus()
Return 1
}
}
Return 0
}

FocusPreviousControl() {
If This.ChildControls.Length > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found <= 1
This.CurrentControlID := This.FocusableControlIDs[This.FocusableControlIDs.Length]
Else
This.CurrentControlID := This.FocusableControlIDs[Found - 1]
This.SetCurrentControlID(This.CurrentControlID)
CurrentControl := AccessibilityOverlay.GetControl(This.CurrentControlID)
If CurrentControl.HasMethod("Focus") {
CurrentControl.Focus()
Return 1
}
}
Return 0
}

FocusNextTab() {
If This.ChildControls.Length > 0 And This.CurrentControlID > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found > 0 {
CurrentControl := AccessibilityOverlay.GetControl(This.FocusableControlIDs[Found])
If CurrentControl Is TabControl {
If CurrentControl.CurrentTab < CurrentControl.Tabs.Length
TabNumber := CurrentControl.CurrentTab + 1
Else
TabNumber := 1
CurrentControl.CurrentTab := TabNumber
CurrentControl.Focus()
Return 1
}
}
}
Return 0
}

FocusPreviousTab() {
If This.ChildControls.Length > 0 And This.CurrentControlID > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found > 0 {
CurrentControl := AccessibilityOverlay.GetControl(This.FocusableControlIDs[Found])
If CurrentControl Is TabControl {
If CurrentControl.CurrentTab <= 1
TabNumber := CurrentControl.Tabs.Length
Else
TabNumber := CurrentControl.CurrentTab - 1
CurrentControl.CurrentTab := TabNumber
CurrentControl.Focus()
Return 1
}
}
}
Return 0
}

GetAllControls() {
AllControls := Array()
If This.ChildControls.Length > 0
For CurrentControl In This.ChildControls {
Switch(CurrentControl.__Class) {
Case "AccessibilityOverlay":
AllControls.Push(CurrentControl)
If CurrentControl.ChildControls.Length > 0 {
For ChildControl In CurrentControl.GetAllControls()
AllControls.Push(ChildControl)
}
Case "TabControl":
AllControls.Push(CurrentControl)
If CurrentControl.Tabs.Length > 0 {
For CurrentTab In CurrentControl.Tabs {
AllControls.Push(CurrentTab)
If CurrentTab.ChildControls.Length > 0 {
For CurrentTabControl In CurrentTab.GetAllControls()
AllControls.Push(CurrentTabControl)
}
}
}
Default:
AllControls.Push(CurrentControl)
}
}
Return AllControls
}

GetChildControl(Index) {
Return This.ChildControls.Get(Index, 0)
}

GetCurrentControl() {
Return AccessibilityOverlay.GetControl(This.CurrentControlID)
}

GetCurrentControlID() {
Return This.CurrentControlID
}

GetCurrentControlType() {
CurrentControl := AccessibilityOverlay.GetControl(This.CurrentControlID)
If CurrentControl Is Object
Return CurrentControl.ControlType
Return ""
}

GetFocusableControlIDs() {
FocusableControlIDs := Array()
If This.ChildControls.Length > 0
For CurrentControl In This.ChildControls {
Switch(CurrentControl.__Class) {
Case "AccessibilityOverlay":
If CurrentControl.ChildControls.Length > 0 {
CurrentControl.FocusableControlIDs := CurrentControl.GetFocusableControlIDs()
For CurrentControlID In CurrentControl.FocusableControlIDs
FocusableControlIDs.Push(CurrentControlID)
}
Case "TabControl":
FocusableControlIDs.Push(CurrentControl.ControlID)
If CurrentControl.Tabs.Length > 0 {
CurrentTab := CurrentControl.Tabs[CurrentControl.CurrentTab]
If CurrentTab.ChildControls.Length > 0 {
CurrentTab.FocusableControlIDs := CurrentTab.GetFocusableControlIDs()
For CurrentTabControlID In CurrentTab.FocusableControlIDs
FocusableControlIDs.Push(CurrentTabControlID)
}
}
Default:
FocusableControlIDs.Push(CurrentControl.ControlID)
}
}
Return FocusableControlIDs
}

GetFocusableControls() {
FocusableControls := Array()
This.FocusableControlIDs := This.GetFocusableControlIDs()
For FocusableControlID In This.FocusableControlIDs
FocusableControls.Push(AccessibilityOverlay.GetControl(FocusableControlID))
Return FocusableControls
}

GetHotkeys() {
OverlayHotkeys := Array()
TempList := Map()
For OverlayControl In This.GetAllControls()
If OverlayControl.HasOwnProp("HotkeyCommand") And OverlayControl.HotkeyCommand != ""
TempList.Set(OverlayControl.HotkeyCommand, OverlayControl.HotkeyCommand)
For OverlayHotkey In TempList
OverlayHotkeys.Push(OverlayHotkey)
Return OverlayHotkeys
}

GetReachableControls() {
ReachableControls := Array()
For Value In This.GetFocusableControls()
If Value Is TabControl {
For TabObject In Value.Tabs
ReachableControls.Push(TabObject)
}
Else {
ReachableControls.Push(Value)
}
Return ReachableControls
}

IncreaseSlider() {
If This.ChildControls.Length > 0 And This.CurrentControlID > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found > 0 {
CurrentControl := AccessibilityOverlay.GetControl(This.FocusableControlIDs[Found])
If CurrentControl Is GraphicalSlider {
CurrentControl.Increase()
Return 1
}
}
}
Return 0
}

RemoveControl() {
If This.ChildControls.Length > 0 {
OldList := This.GetFocusableControlIDs()
This.ChildControls.Pop()
This.FocusableControlIDs := This.GetFocusableControlIDs()
NewList := This.FocusableControlIDs
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found = 0 Or OldList[Found] != NewList[Found]
If NewList.Length = 0 {
This.CurrentControlID := 0
}
Else If NewList.Length = 1 {
This.CurrentControlID := NewList[1]
}
Else {
I := NewList.Length
Loop NewList.Length {
If OldList[I] == NewList[I] {
This.CurrentControlID := NewList[I]
Break
}
I--
}
}
This.SetCurrentControlID(This.CurrentControlID)
Return 1
}
Return 0
}

RemoveControlAt(Index) {
If Index > 0 And Index <= This.ChildControls.Length {
OldList := This.GetFocusableControlIDs()
This.ChildControls.RemoveAt(Index)
This.FocusableControlIDs := This.GetFocusableControlIDs()
NewList := This.FocusableControlIDs
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found = 0 Or OldList[Found] != NewList[Found]
If NewList.Length = 0 {
This.CurrentControlID := 0
}
Else If NewList.Length = 1 {
This.CurrentControlID := NewList[1]
}
Else {
I := NewList.Length
Loop NewList.Length {
If OldList[I] == NewList[I] {
This.CurrentControlID := NewList[I]
Break
}
I--
}
}
This.SetCurrentControlID(This.CurrentControlID)
Return 1
}
Return 0
}

Reset() {
This.CurrentControlID := 0
If This.ChildControls.Length > 0 {
For CurrentControl In This.ChildControls
Switch(CurrentControl.__Class) {
Case "AccessibilityOverlay":
If CurrentControl.ChildControls.Length > 0 {
CurrentControl.CurrentControlID := 0
CurrentControl.Reset()
}
Case "TabControl":
If CurrentControl.Tabs.Length > 0 {
CurrentControl.CurrentTab := 1
For CurrentTab In CurrentControl.Tabs
If CurrentTab.ChildControls.Length > 0 {
CurrentTab.CurrentControlID := 0
CurrentTab.Reset()
}
}
}
}
}

SelectNextOption() {
If This.ChildControls.Length > 0 And This.CurrentControlID > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found > 0 {
CurrentControl := AccessibilityOverlay.GetControl(This.FocusableControlIDs[Found])
If CurrentControl.ControlType = "ComboBox" {
CurrentOption := CurrentControl.CurrentOption
CurrentControl.SelectNextOption()
If CurrentOption != CurrentControl.CurrentOption
CurrentControl.ReportValue()
Return 1
}
}
}
Return 0
}

SelectPreviousOption() {
If This.ChildControls.Length > 0 And This.CurrentControlID > 0 {
This.FocusableControlIDs := This.GetFocusableControlIDs()
Found := This.FindFocusableControlID(This.CurrentControlID)
If Found > 0 {
CurrentControl := AccessibilityOverlay.GetControl(This.FocusableControlIDs[Found])
If CurrentControl.ControlType = "ComboBox" {
CurrentOption := CurrentControl.CurrentOption
CurrentControl.SelectPreviousOption()
If CurrentOption != CurrentControl.CurrentOption
CurrentControl.ReportValue()
Return 1
}
}
}
Return 0
}

SetCurrentControlID(ControlID) {
If This.ChildControls.Length > 0 {
This.CurrentControlID := ControlID
For CurrentControl In This.ChildControls {
Switch(CurrentControl.__Class) {
Case "AccessibilityOverlay":
If CurrentControl.ChildControls.Length > 0 {
Found := CurrentControl.FindFocusableControlID(ControlID)
If Found > 0
CurrentControl.SetCurrentControlID(ControlID)
Else
CurrentControl.CurrentControlID := 0
}
Else {
CurrentControl.CurrentControlID := 0
}
Case "TabControl":
If CurrentControl.Tabs.Length > 0 {
CurrentTab := CurrentControl.Tabs[CurrentControl.CurrentTab]
If CurrentTab.ChildControls.Length > 0 {
Found := CurrentTab.FindFocusableControlID(ControlID)
If Found > 0
CurrentTab.SetCurrentControlID(ControlID)
Else
CurrentTab.CurrentControlID := 0
}
Else {
CurrentTab.CurrentControlID := 0
}
}
}
}
}
Else {
This.CurrentControlID := 0
}
}

TriggerHotkey(HotkeyCommand) {
For ReachableControl In This.GetReachableControls()
If ReachableControl.HasOwnProp("HotkeyCommand") And ReachableControl.HotkeyCommand = HotkeyCommand
If ReachableControl.ControlType = "Tab" {
ParentTabControl := ReachableControl.GetSuperordinateControl()
SiblingTab := ParentTabControl.GetCurrentTab()
For Index, Value In ParentTabControl.Tabs
If Value = ReachableControl {
ParentTabControl.CurrentTab := Index
If ReachableControl.ControlID != SiblingTab.ControlID {
This.FocusControl(ParentTabControl.ControlID)
}
Else {
If This.GetCurrentControlID() != ParentTabControl.ControlID
This.FocusControl(ParentTabControl.ControlID)
Else
ReachableControl.Focus(ReachableControl.controlID)
This.SetCurrentControlID(ParentTabControl.ControlID)
}
For HotkeyFunction In ReachableControl.HotkeyFunction
HotkeyFunction.Call(ReachableControl)
Break 2
}
}
Else {
If ReachableControl.HasMethod("Activate")
This.ActivateControl(ReachableControl.ControlID)
Else
This.FocusControl(ReachableControl.ControlID)
For HotkeyFunction In ReachableControl.HotkeyFunction
HotkeyFunction.Call(ReachableControl)
Break
}
}

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

Static GetAllControls() {
Return AccessibilityOverlay.AllControls
}

Static GetControl(ControlID) {
If ControlID > 0 And AccessibilityOverlay.AllControls.Length > 0 And AccessibilityOverlay.AllControls.Length >= ControlID
Return AccessibilityOverlay.AllControls[ControlID]
Return 0
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
If Message != "" {
AccessibilityOverlay.LastMessage := Message
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
}

Static StopSpeech() {
If (AccessibilityOverlay.JAWS != False Or !ProcessExist("jfw.exe")) And (!FileExist("NvdaControllerClient" . A_PtrSize * 8 . ".dll") Or DllCall("NvdaControllerClient" . A_PtrSize * 8 . ".dll\nvdaController_testIfRunning"))
If AccessibilityOverlay.SAPI != False
AccessibilityOverlay.SAPI.Speak("", 0x1|0x2)
}

}

Class FocusableControl {

ControlID := 0
ControlType := "Focusable"
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
If This.HasMethod("ExecuteOnFocusPreSpeech")
This.ExecuteOnFocusPreSpeech()
This.SpeakOnFocus(Speak)
If This.HasMethod("ExecuteOnFocusPostSpeech")
This.ExecuteOnFocusPostSpeech()
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

SpeakOnFocus(Speak := True) {
Message := ""
CheckResult := This.State
LabelString := This.Label
If LabelString = ""
LabelString := This.DefaultLabel
ValueString := This.GetValue()
If ValueString = ""
ValueString := This.DefaultValue
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID {
Message := LabelString . " " . This.ControlTypeLabel . " " . ValueString . " " . StateString . " " . This.HotkeyLabel
If Speak
AccessibilityOverlay.Speak(Message)
}
}

}

Class ActivatableControl Extends FocusableControl {

ActivationFunctions := Array()
ControlType := "Activatable"

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
If This.HasMethod("ExecuteOnActivationPreSpeech")
This.ExecuteOnActivationPreSpeech()
This.SpeakOnActivation(Speak)
If This.HasMethod("ExecuteOnActivationPostSpeech")
This.ExecuteOnActivationPostSpeech()
}
}
}

SpeakOnActivation(Speak := True) {
Message := ""
CheckResult := This.State
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
Message := LabelString . " " . This.ControlTypeLabel . " " . ValueString . " " . StateString
Else
If This.ControlID = AccessibilityOverlay.CurrentControlID And This.ControlID = AccessibilityOverlay.PreviousControlID And This.states.Length > 1
Message := StateString
If Speak
AccessibilityOverlay.Speak(Message)
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
If This.HasMethod("ExecuteOnFocusPreSpeech")
This.ExecuteOnFocusPreSpeech()
This.SpeakOnFocus(Speak)
If This.HasMethod("ExecuteOnFocusPostSpeech")
This.ExecuteOnFocusPostSpeech()
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

SpeakOnFocus(Speak := True) {
Message := ""
CheckResult := This.State
LabelString := This.Label
If LabelString = ""
LabelString := This.DefaultLabel
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID {
Message := LabelString . " " . This.ControlTypeLabel . " " . StateString . " " . This.HotkeyLabel
AccessibilityOverlay.LastMessage := Message
If Speak
AccessibilityOverlay.Speak(Message)
}
}

}

Class TabControl Extends FocusableControl {

ControlType := "TabControl"
ControlTypeLabel := "tab control"
CurrentTab := 1
Tabs := Array()

__New(Label := "", Tabs*) {
Super.__New(Label)
If Tabs.Length > 0
For TabObject In Tabs
This.AddTabs(TabObject)
}

AddTabs(Tabs*) {
If Tabs.Length > 0
For TabObject In Tabs {
TabObject.SuperordinateControlID := This.ControlID
This.Tabs.Push(TabObject)
}
}

GetCurrentTab() {
Return This.Tabs.Get(This.CurrentTab, 0)
}

GetTab(TabNumber) {
Return This.Tabs.Get(TabNumber, 0)
}

GetValue() {
Value := ""
CurrentTab := This.GetCurrentTab()
If CurrentTab Is Object And CurrentTab.ControlType = "Tab" {
CurrentTab.Focus(False)
If CurrentTab.Focused = 1
Value := AccessibilityOverlay.LastMessage
}
This.Value := Value
Return This.Value
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

Class GraphicalButton Extends Button {
}

Class GraphicalCheckbox Extends CheckBox {
}

Class GraphicalSlider Extends FocusableControl {
}

Class GraphicalHorizontalSlider Extends GraphicalSlider {
}

Class GraphicalVerticalSlider Extends GraphicalSlider {
}

Class GraphicalTab Extends Tab {
}

Class HotspotButton Extends Button {

XCoordinate := 0
YCoordinate := 0

__New(Label, XCoordinate, YCoordinate, FocusFunctions := "", ActivationFunctions := "") {
Super.__New(Label, FocusFunctions, ActivationFunctions)
This.XCoordinate := XCoordinate
This.YCoordinate := YCoordinate
}

ExecuteOnActivationPostSpeech() {
Click This.XCoordinate, This.YCoordinate
}

ExecuteOnFocusPostSpeech() {
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

ExecuteOnActivationPostSpeech() {
Click This.XCoordinate, This.YCoordinate
}

ExecuteOnFocusPostSpeech() {
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

ExecuteOnFocusPostSpeech() {
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

ExecuteOnFocusPostSpeech() {
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

ExecuteOnFocusPostSpeech() {
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

ExecuteOnActivationPostSpeech() {
Click This.XCoordinate, This.YCoordinate
}

ExecuteOnFocusPostSpeech() {
MouseMove This.XCoordinate, This.YCoordinate
}

}

Class NativeControl Extends ActivatableControl {

ControlType := "Native"
NativeControlID := ""
States := Map("-1", "Can not focus control", "0", "not found", "1", "")

__New(NativeControlID, Label := "", FocusFunctions := "", ActivationFunctions := "") {
Super.__New(Label, FocusFunctions, ActivationFunctions)
This.NativeControlID := NativeControlID
}

CheckFocus() {
Try
Found := ControlGetHwnd(This.NativeControlID, "A")
Catch
Found := False
If Not Found {
This.Focused := 0
AccessibilityOverlay.Speak(This.States["0"])
}
Else {
Try {
This.Focused := 1
ControlFocus This.NativeControlID, "A"
}
Catch {
This.Focused := 0
This.State := -1
AccessibilityOverlay.Speak(This.States["-1"])
}
If This.Focused
Return True
}
Return False
}

CheckState() {
If This.Focused = 0
Return False
Try
Found := ControlGetHwnd(This.NativeControlID, "A")
Catch
Found := False
If Found {
This.State := 1
Return True
}
Else {
This.State := 0
Return False
}
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

ExecuteOnActivationPostSpeech() {
XCoordinate := This.X1Coordinate + Floor((This.X2Coordinate - This.X1Coordinate)/2)
YCoordinate := This.Y1Coordinate + Floor((This.Y2Coordinate - This.Y1Coordinate)/2)
Click XCoordinate, YCoordinate
}

ExecuteOnFocusPostSpeech() {
XCoordinate := This.X1Coordinate + Floor((This.X2Coordinate - This.X1Coordinate)/2)
YCoordinate := This.Y1Coordinate + Floor((This.Y2Coordinate - This.Y1Coordinate)/2)
MouseMove XCoordinate, YCoordinate
}

SpeakOnActivation(Speak := True) {
Message := ""
CheckResult := This.State
LabelString := AccessibilityOverlay.OCR(This.X1Coordinate, This.Y1Coordinate, This.X2Coordinate, This.Y2Coordinate, This.OCRLanguage, This.OCRScale)
This.Label := LabelString
If LabelString = ""
LabelString := This.DefaultLabel
StateString := ""
If This.states.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID = AccessibilityOverlay.CurrentControlID And This.ControlID != AccessibilityOverlay.PreviousControlID
Message := LabelString . " " . This.ControlTypeLabel . " " . StateString
Else
If This.ControlID = AccessibilityOverlay.CurrentControlID And This.ControlID = AccessibilityOverlay.PreviousControlID And This.states.Length > 1
Message := StateString
If Speak
AccessibilityOverlay.Speak(Message)
}

SpeakOnFocus(Speak := True) {
Message := ""
CheckResult := This.State
LabelString := AccessibilityOverlay.OCR(This.X1Coordinate, This.Y1Coordinate, This.X2Coordinate, This.Y2Coordinate, This.OCRLanguage, This.OCRScale)
If LabelString = ""
LabelString := This.DefaultLabel
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID {
Message := LabelString . " " . This.ControlTypeLabel . " " . StateString . " " . This.HotkeyLabel
If Speak
AccessibilityOverlay.Speak(Message)
}
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

ExecuteOnFocusPostSpeech() {
XCoordinate := This.X1Coordinate + Floor((This.X2Coordinate - This.X1Coordinate)/2)
YCoordinate := This.Y1Coordinate + Floor((This.Y2Coordinate - This.Y1Coordinate)/2)
Click XCoordinate, YCoordinate
}

GetValue() {
This.Value := AccessibilityOverlay.OCR(This.X1Coordinate, This.Y1Coordinate, This.X2Coordinate, This.Y2Coordinate, This.OCRLanguage, This.OCRScale)
Return This.Value
}

SpeakOnFocus(Speak := True) {
Message := ""
CheckResult := This.State
LabelString := This.Label
If LabelString = ""
LabelString := This.DefaultLabel
ValueString := This.GetValue()
If ValueString = ""
ValueString := This.DefaultValue
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID {
Message := LabelString . " " . This.ControlTypeLabel . " " . ValueString . " " . StateString . " " . This.HotkeyLabel
If Speak
AccessibilityOverlay.Speak(Message)
}
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

ExecuteOnFocusPostSpeech() {
XCoordinate := This.X1Coordinate + Floor((This.X2Coordinate - This.X1Coordinate)/2)
YCoordinate := This.Y1Coordinate + Floor((This.Y2Coordinate - This.Y1Coordinate)/2)
Click XCoordinate, YCoordinate
}

GetValue() {
This.Value := AccessibilityOverlay.OCR(This.X1Coordinate, This.Y1Coordinate, This.X2Coordinate, This.Y2Coordinate, This.OCRLanguage, This.OCRScale)
Return This.Value
}

SpeakOnFocus(Speak := True) {
Message := ""
CheckResult := This.State
LabelString := This.Label
If LabelString = ""
LabelString := This.DefaultLabel
ValueString := This.GetValue()
If ValueString = ""
ValueString := This.DefaultValue
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID {
Message := LabelString . " " . This.ControlTypeLabel . " " . ValueString . " " . StateString . " " . This.HotkeyLabel
If Speak
AccessibilityOverlay.Speak(Message)
}
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

ExecuteOnFocusPostSpeech() {
XCoordinate := This.X1Coordinate + Floor((This.X2Coordinate - This.X1Coordinate)/2)
YCoordinate := This.Y1Coordinate + Floor((This.Y2Coordinate - This.Y1Coordinate)/2)
Click XCoordinate, YCoordinate
}

SpeakOnFocus(Speak := True) {
Message := ""
CheckResult := This.State
LabelString := AccessibilityOverlay.OCR(This.X1Coordinate, This.Y1Coordinate, This.X2Coordinate, This.Y2Coordinate, This.OCRLanguage, This.OCRScale)
This.Label := LabelString
If LabelString = ""
LabelString := This.DefaultLabel
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID {
Message := LabelString . " " . This.ControlTypeLabel . " " . StateString . " " . This.HotkeyLabel
If Speak
AccessibilityOverlay.Speak(Message)
}
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

SpeakOnFocus(Speak := True) {
Message := ""
CheckResult := This.State
LabelString := AccessibilityOverlay.OCR(This.X1Coordinate, This.Y1Coordinate, This.X2Coordinate, This.Y2Coordinate, This.OCRLanguage, This.OCRScale)
This.Label := LabelString
If LabelString = ""
LabelString := This.DefaultLabel
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID {
Message := LabelString . " " . StateString . " " . This.HotkeyLabel
If Speak
AccessibilityOverlay.Speak(Message)
}
}

}

Class StaticText Extends FocusableControl {

ControlType := "Text"

SpeakOnFocus(Speak := True) {
Message := ""
CheckResult := This.State
LabelString := This.Label
If LabelString = ""
LabelString := This.DefaultLabel
StateString := ""
If This.States.Has(CheckResult)
StateString := This.States[CheckResult]
If This.ControlID != AccessibilityOverlay.CurrentControlID {
Message := LabelString . " " . StateString . " " . This.HotkeyLabel
If Speak
AccessibilityOverlay.Speak(Message)
}
}

}

Class ToggleButton Extends Button {

States := Map("-1", "unknown state", "0", "off", "1", "on")

}

Class UIAControl Extends ActivatableControl {

ControlType := "UIA"
States := Map("0", "not found", "1", "")
UIAPath := ""

__New(UIAPath, Label := "", FocusFunctions := "", ActivationFunctions := "") {
Super.__New(Label, FocusFunctions, ActivationFunctions)
This.UIAPath := UIAPath
}

ExecuteOnActivationPostSpeech() {
Try {
element := This.GetElement()
element.Click("Left")
}
}

ExecuteOnFocusPreSpeech() {
Try {
element := This.GetElement()
element.SetFocus()
}
}

CheckFocus() {
Try
Found := This.GetControl()
Catch
Found := False
If Not Found {
This.Focused := 0
AccessibilityOverlay.Speak(This.States["0"])
}
Else {
This.Focused := 1
Return True
}
Return False
}

CheckState() {
Try
Found := This.GetElement()
Catch
Found := False
If Found {
This.State := 1
Return True
}
Else {
This.State := 0
Return False
}
}

GetElement() {
If !IsSet(UIA)
Return False
Try {
element := UIA.ElementFromHandle("ahk_id " . WinGetID("A"))
element := element.ElementFromPath(This.UIAPath)
}
Catch {
Return False
}
Return Element
}

}
