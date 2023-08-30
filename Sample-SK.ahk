#Requires AutoHotkey v2.0

#Include AccessibilityOverlay.ahk

#MaxThreadsPerHotkey 1
#SingleInstance Force
#Warn
SendMode "Input"
SetWorkingDir A_InitialWorkingDir
CoordMode "Mouse", "Window"
CoordMode "Pixel", "Window"

AppName := "Skript pre Poznámkový blok"

AccessibilityOverlay.Speak(AppName . " pripravený")

NotepadOverlay := AccessibilityOverlay()
NotepadOverlay.AddHotspotButton("Hlavné tlačidlo 1", 120, 180)
NotepadOverlay.AddHotspotButton("Hlavné tlačidlo 2", 180, 180)
MainTabControl := NotepadOverlay.AddTabControl()
GeneralTab := HotspotTab("Všeobecné", 360, 240)
NestedOverlay := GeneralTab.AddAccessibilityOverlay()
NestedOverlay.AddHotspotButton("Vnorené tlačidlo 1", 60, 320)
NestedOverlay.AddHotspotButton("Vnorené tlačidlo 2", 120, 320)
NestedTabControl := NestedOverlay.AddTabControl()
NestedTab1 := HotspotTab("Vnorená záložka 1", 60, 400)
NestedTab1Button1 := NestedTab1.AddHotspotButton("Tlačidlo 1", 60, 460)
NestedTab1.AddHotspotButton("Tlačidlo 2", 240, 460)
NestedTab1.AddHotspotButton("Tlačidlo 3", 300, 460)
NestedTab2 := HotspotTab("Vnorená záložka 2", 60, 400)
NestedTab2.AddHotspotButton("Voľba 1", 60, 460)
NestedTab2.AddHotspotButton("Voľba 2", 240, 460)
NestedTab2.AddHotspotButton("Voľba 3", 300, 460)
NestedTabControl.AddTabs(NestedTab1, NestedTab2)
GeneralTab.AddHotspotButton("Všeobecné tlačidlo 1", 60, 320)
GeneralTab.AddHotspotButton("Všeobecné tlačidlo 2", 120, 320)
GeneralTab.AddHotspotButton("Všeobecné tlačidlo 3", 180, 320)
GeneralTab.AddHotspotButton("Všeobecné tlačidlo 4", 240, 320)
AdvancedTab := HotspotTab("Pokročilé", 420, 240)
AdvancedTab.AddHotspotButton("Pokročilé tlačidlo 1", 60, 320)
AdvancedTabControl := AdvancedTab.AddTabControl()
OptionsTab := HotspotTab("Nastavenia", 60, 400)
OptionsTab.AddHotspotButton("Nastavenie 1", 60, 460)
OptionsTab.AddHotspotButton("Nastavenie 2", 240, 460)
OptionsTab.AddHotspotButton("Nastavenie 3", 300, 460)
AppearanceTab := HotspotTab("Vzhľad", 60, 400)
AppearanceTab.AddHotspotButton("Možnosť 1", 60, 460)
AppearanceTab.AddHotspotButton("Možnosť 2", 240, 460)
AppearanceTab.AddHotspotButton("Možnosť 3", 300, 460)
AdvancedTabControl.AddTabs(OptionsTab, AppearanceTab)
AdvancedTab.AddHotspotButton("Pokročilé tlačidlo 2", 120, 320)
MainTabControl.AddTabs(GeneralTab, AdvancedTab)
NotepadOverlay.Translate("Slovak")

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
    AccessibilityOverlay.Speak(AppName . " zresetovaný")
}
