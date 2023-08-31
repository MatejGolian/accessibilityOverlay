#Requires AutoHotkey v2.0

#Include AccessibilityOverlay.ahk
#Include OCR.ahk

#MaxThreadsPerHotkey 1
#SingleInstance Force
#Warn
SendMode "Input"
SetWorkingDir A_InitialWorkingDir
CoordMode "Mouse", "Window"
CoordMode "Pixel", "Window"

AppName := "Script for Notepad"

AccessibilityOverlay.Speak(AppName . " ready")

NotepadOverlay := AccessibilityOverlay()
NotepadOverlay.AddHotspotButton("Main button 1", 120, 180)
NotepadOverlay.AddHotspotButton("Main button 2", 180, 180)
MainTabControl := NotepadOverlay.AddTabControl()
GeneralTab := HotspotTab("General", 360, 240)
NestedOverlay := GeneralTab.AddAccessibilityOverlay()
NestedOverlay.AddHotspotButton("Nested button 1", 60, 320)
NestedOverlay.AddHotspotButton("Nested button 2", 120, 320)
NestedTabControl := NestedOverlay.AddTabControl()
NestedTab1 := HotspotTab("Nested tab 1", 60, 400)
NestedTab1Button1 := NestedTab1.AddHotspotButton("Button 1", 60, 460)
NestedTab1.AddHotspotButton("Button 2", 240, 460)
NestedTab1.AddHotspotButton("Button 3", 300, 460)
NestedTab2 := HotspotTab("Nested tab 2", 60, 400)
NestedTab2.AddHotspotButton("Option 1", 60, 460)
NestedTab2.AddHotspotButton("Option 2", 240, 460)
NestedTab2.AddHotspotButton("Option 3", 300, 460)
NestedTabControl.AddTabs(NestedTab1, NestedTab2)
GeneralTab.AddHotspotButton("General button 1", 60, 320)
GeneralTab.AddHotspotButton("General button 2", 120, 320)
GeneralTab.AddHotspotButton("General button 3", 180, 320)
GeneralTab.AddHotspotButton("General button 4", 240, 320)
AdvancedTab := HotspotTab("Advanced", 420, 240)
AdvancedTab.AddHotspotButton("Advanced button 1", 60, 320)
AdvancedTabControl := AdvancedTab.AddTabControl()
OptionsTab := HotspotTab("Options", 60, 400)
OptionsTab.AddHotspotButton("Option 1", 60, 460)
OptionsTab.AddHotspotButton("Option 2", 240, 460)
OptionsTab.AddHotspotButton("Option 3", 300, 460)
AppearanceTab := HotspotTab("Appearance", 60, 400)
AppearanceTab.AddHotspotButton("Choice 1", 60, 460)
AppearanceTab.AddHotspotButton("Choice 2", 240, 460)
AppearanceTab.AddHotspotButton("Choice 3", 300, 460)
AdvancedTabControl.AddTabs(OptionsTab, AppearanceTab)
AdvancedTab.AddHotspotButton("Advanced button 2", 120, 320)
MainTabControl.AddTabs(GeneralTab, AdvancedTab)

#HotIf WinActive("ahk_exe notepad.exe")

Tab::NotepadOverlay.FocusNextControl()
+Tab::NotepadOverlay.FocusPreviousControl()
Right::
^Tab::NotepadOverlay.FocusNextTab()
Left::
^+Tab::NotepadOverlay.FocusPreviousTab()
^A::NotepadOverlay.ActivateControl(NestedTab1Button1.ControlID)
^F::NotepadOverlay.FocusControl(NestedTab1Button1.ControlID)
Space::
Enter::NotepadOverlay.ActivateCurrentControl()
Ctrl::AccessibilityOverlay.StopSpeech()

^R:: {
    Global AppName, NotepadOverlay
    NotepadOverlay.Reset()
    AccessibilityOverlay.Speak(AppName . " reset")
}
