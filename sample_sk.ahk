#requires autoHotkey v2.0

#include accessibilityOverlay.ahk

#maxThreadsPerHotkey 1
#singleInstance force
#warn
sendMode "input"
setWorkingDir a_initialWorkingDir
coordMode "mouse", "window"
coordMode "pixel", "Window"

appName := "Skript pre Poznámkový blok"

accessibilityOverlay.speak(appName . " pripravený")

notepadOverlay := accessibilityOverlay()
notepadOverlay.addHotspotButton("Hlavné tlačidlo 1", 120, 180)
notepadOverlay.addHotspotButton("Hlavné tlačidlo 2", 180, 180)
mainTabControl := notepadOverlay.addTabControl()
generalTab := hotspotTab("Všeobecné", 360, 240)
nestedOverlay := generalTab.addAccessibilityOverlay()
nestedOverlay.addHotspotButton("Vnorené tlačidlo 1", 60, 320)
nestedOverlay.addHotspotButton("Vnorené tlačidlo 2", 120, 320)
nestedTabControl := nestedOverlay.addTabControl()
nestedTab1 := hotspotTab("Vnorená záložka 1", 60, 400)
nestedTab1Button1 := nestedTab1.addHotspotButton("Tlačidlo 1", 60, 460)
nestedTab1.addHotspotButton("Tlačidlo 2", 240, 460)
nestedTab1.addHotspotButton("Tlačidlo 3", 300, 460)
nestedTab2 := hotspotTab("Vnorená záložka 2", 60, 400)
nestedTab2.addHotspotButton("Voľba 1", 60, 460)
nestedTab2.addHotspotButton("Voľba 2", 240, 460)
nestedTab2.addHotspotButton("Voľba 3", 300, 460)
nestedTabControl.addTabs(NestedTab1, nestedTab2)
generalTab.addHotspotButton("Všeobecné tlačidlo 1", 60, 320)
generalTab.addHotspotButton("Všeobecné tlačidlo 2", 120, 320)
generalTab.addHotspotButton("Všeobecné tlačidlo 3", 180, 320)
generalTab.addHotspotButton("Všeobecné tlačidlo 4", 240, 320)
advancedTab := hotspotTab("Pokročilé", 420, 240)
advancedTab.addHotspotButton("Pokročilé tlačidlo 1", 60, 320)
advancedTabControl := advancedTab.addTabControl()
optionsTab := hotspotTab("Nastavenia", 60, 400)
optionsTab.addHotspotButton("Nastavenie 1", 60, 460)
optionsTab.addHotspotButton("Nastavenie 2", 240, 460)
optionsTab.addHotspotButton("Nastavenie 3", 300, 460)
appearanceTab := hotspotTab("Vzhľad", 60, 400)
appearanceTab.addHotspotButton("Možnosť 1", 60, 460)
appearanceTab.addHotspotButton("Možnosť 2", 240, 460)
appearanceTab.addHotspotButton("Možnosť 3", 300, 460)
advancedTabControl.addTabs(OptionsTab, appearanceTab)
advancedTab.addHotspotButton("Pokročilé tlačidlo 2", 120, 320)
mainTabControl.addTabs(GeneralTab, advancedTab)
notepadOverlay.translate("Slovak")

#hotIf winActive("ahk_exe notepad.exe") ; Restrict the script to Notepad

tab::notepadOverlay.focusNextControl()
+tab::notepadOverlay.focusPreviousControl()
right::
^tab::notepadOverlay.focusNextTab()
left::
^+tab::notepadOverlay.focusPreviousTab()
^a::notepadOverlay.activateControl(NestedTab1Button1.controlID)
^f::notepadOverlay.focusControl(NestedTab1Button1.controlID)
space::
enter::notepadOverlay.activateCurrentControl()
cTRL::accessibilityOverlay.stopSpeech()

^r:: {
    global appName, notepadOverlay
    notepadOverlay.reset()
    accessibilityOverlay.speak(appName . " zresetovaný")
}
