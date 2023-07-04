#requires autoHotkey v2.0

#include accessibilityOverlay.ahk

#maxThreadsPerHotkey 1
#singleInstance force
#warn
sendMode "input"
setWorkingDir a_initialWorkingDir
coordMode "mouse", "window"
coordMode "pixel", "Window"

appName := "Script for Notepad"

accessibilityOverlay.speak(appName . " ready")

notepadOverlay := accessibilityOverlay()
notepadOverlay.addHotspotButton("Main button 1", 120, 180)
notepadOverlay.addHotspotButton("Main button 2", 180, 180)
mainTabControl := notepadOverlay.addTabControl()
generalTab := hotspotTab("General", 360, 240)
nestedOverlay := generalTab.addAccessibilityOverlay()
nestedOverlay.addHotspotButton("Nested button 1", 60, 320)
nestedOverlay.addHotspotButton("Nested button 2", 120, 320)
nestedTabControl := nestedOverlay.addTabControl()
nestedTab1 := hotspotTab("Nested tab 1", 60, 400)
nestedTab1Button1 := nestedTab1.addHotspotButton("Button 1", 60, 460)
nestedTab1.addHotspotButton("Button 2", 240, 460)
nestedTab1.addHotspotButton("Button 3", 300, 460)
nestedTab2 := hotspotTab("Nested tab 2", 60, 400)
nestedTab2.addHotspotButton("Option 1", 60, 460)
nestedTab2.addHotspotButton("Option 2", 240, 460)
nestedTab2.addHotspotButton("Option 3", 300, 460)
nestedTabControl.addTabs(NestedTab1, nestedTab2)
generalTab.addHotspotButton("General button 1", 60, 320)
generalTab.addHotspotButton("General button 2", 120, 320)
generalTab.addHotspotButton("General button 3", 180, 320)
generalTab.addHotspotButton("General button 4", 240, 320)
advancedTab := hotspotTab("Advanced", 420, 240)
advancedTab.addHotspotButton("Advanced button 1", 60, 320)
advancedTabControl := advancedTab.addTabControl()
optionsTab := hotspotTab("Options", 60, 400)
optionsTab.addHotspotButton("Option 1", 60, 460)
optionsTab.addHotspotButton("Option 2", 240, 460)
optionsTab.addHotspotButton("Option 3", 300, 460)
appearanceTab := hotspotTab("Appearance", 60, 400)
appearanceTab.addHotspotButton("Choice 1", 60, 460)
appearanceTab.addHotspotButton("Choice 2", 240, 460)
appearanceTab.addHotspotButton("Choice 3", 300, 460)
advancedTabControl.addTabs(OptionsTab, appearanceTab)
advancedTab.addHotspotButton("Advanced button 2", 120, 320)
mainTabControl.addTabs(GeneralTab, advancedTab)

#hotIf winActive("ahk_exe notepad.exe")

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
    accessibilityOverlay.speak(appName . " reset")
}
