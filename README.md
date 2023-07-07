# What It Is
This is a set of classes written in AutoHotkey 2 that makes it possible to simulate accessible user interface elements by combining AutoHotkey functionality with screen reader output. It was specifically written to address the needs of blind users who often require a large number of keyboard shortcuts when creating AHK-based accessibility solutions for otherwise inaccessible applications.
## Requirements
1. AutoHotkey version 2
2. The NVDA screen reader or Microsoft SAPI voices installed on your system
3. In case you want to use NVDA for speech output, you'll need a copy of the nvdaControllerClient DLL depending on your build of AutoHotkey. The nvdaControllerClient DLL is available both in 32 and 64-bit and both versions can be downloaded at the following location: http://www.nvda-project.org/nvdaControllerClient/nvdaControllerClient_20100219.7z
   * Use nvdaControllerClient32.dll with the 32-bit version of AutoHotkey.
   * Use nvdaControllerClient64.dll with the 64-bit version of AutoHotkey.
## How It Works
You define elements using the classes found in the "accessibilityOverlay.ahk" file. These elements then get automatically voiced either by NVDA or Microsoft SAPI.
* If NVDA is running and if the appropriate copy of the nvdaControllerClient DLL is located in your script directory, the elements are automatically voiced using NVDA.
* If NVDA is not running or if the appropriate copy of the nvdaControllerClient DLL can not be found in your script directory, the elements are automatically voiced using Microsoft SAPI.
### Basic Usage Example
```
#include accessibilityOverlay.ahk ; Include the overlay classes in the script

appName := "My App"

accessibilityOverlay.speak(appName . " ready") ; Make NVDA or SAPI report that your script has been launched

overlay := accessibilityOverlay() ; Create a new overlay object
overlay.addHotspotButton("Main button 1", 120, 180) ; Add a button that will get clicked at the coordinates specified once it's activated
overlay.addHotspotButton("Main button 2", 180, 180) ; Add a second button
mainTabControl := overlay.addTabControl("Pages") ; Add a tab control to the overlay object and label it "Pages"
basicTab := hotspotTab("Basic", 900, 292) ; Create a new tab object that will get clicked at the coordinates specified once it's selected
basicTab.addHotspotButton("Basic button 1", 640, 404) ; Add a button to this tab
basicTab.addHotspotButton("Basic button 2", 716, 404) ; Add a second button
basicTab.addHotspotButton("Basic button 3", 790, 404) ; Add a third button
advancedTab := hotspotTab("Advanced", 1048, 292) ; Create a second tab object labelled "Advanced"
advancedTab.addHotspotButton("Advanced button 1", 640, 480) ; Add the first button to this tab
advancedTab.addHotspotButton("Advanced button 2", 716, 480) ; Add a second button
advancedTab.addHotspotButton("Advanced button 3", 790, 480) ; Add a third button
mainTabControl.addTabs(basicTab, advancedTab) ; Add the 2 previously created tabs to the tab control object we defined before

#hotIf winActive("ahk_exe notepad.exe") ; Restrict the script to Notepad

; Set up keyboard shortcuts and navigation (items wrap automatically)
Tab::Overlay.focusNextControl() ; Move focus to the next control
+Tab::Overlay.focusPreviousControl() ; Move focus to the previous control
Right::Overlay.focusNextTab() ; If the current control is a tab control use the right arrow to focus the next tab
Left::Overlay.focusPreviousTab() ; If the current control is a tab control use the left arrow to focus the previous tab
Enter::Overlay.activateCurrentControl() ; Activate the currently focused control
Ctrl::accessibilityOverlay.stopSpeech() ; Stops SAPI (does not do anything in case of NVDA, since that's not needed)

^R:: { ; Resets the overlay
    global appName, overlay
    overlay.reset()
    accessibilityOverlay.speak(appName . " reset")
}
```
### Firing Extra/Custom Functions
When creating elements such as buttons and tabs, you can optionally supply the names of functions that will be executed either after the given control receives focus or once its activated. These functions are always the last parameters expected by the constructors and the calling object is automatically passed on to them as a parameter. Tab objects only support firing functions on focus, while buttons support firing functions on activation as well.
For instance, here is how to create an overlay with buttons that fire user defined functions:
```
#include accessibilityOverlay.ahk ; Include the overlay classes in the script

appName := "My App"

accessibilityOverlay.speak(appName . " ready") ; Make NVDA or SAPI report that your script has been launched

overlay := accessibilityOverlay() ; Create a new overlay object
overlay.addHotspotButton("Button 1", 120, 180, "focusButton", "activateButton") ; Add a button that will get clicked at the coordinates specified once it's activated and make it trigger the "focusButton" and "activateButton" functions
overlay.addHotspotButton("Button 2", 180, 180, "focusButton", "activateButton") ; Add a second button

#hotIf winActive("ahk_exe notepad.exe") ; Restrict the script to Notepad

; Set up keyboard shortcuts and navigation (items wrap automatically)
Tab::Overlay.focusNextControl() ; Move focus to the next control
+Tab::Overlay.focusPreviousControl() ; Move focus to the previous control
Right::Overlay.focusNextTab() ; If the current control is a tab control use the right arrow to focus the next tab
Left::Overlay.focusPreviousTab() ; If the current control is a tab control use the left arrow to focus the previous tab
Enter::Overlay.activateCurrentControl() ; Activate the currently focused control
Ctrl::accessibilityOverlay.stopSpeech() ; Stops SAPI (does not do anything in case of NVDA, since that's not needed)

^R:: { ; Resets the overlay
    global appName, overlay
    overlay.reset()
    accessibilityOverlay.speak(appName . " reset")
}

return ; End auto-execute section

focusButton(button) { ; Define function
    global appName
    ; Do something when a given button receives focus, like
    msgBox button.label, appName ; Dysplay a standard AHK message box with the label of the currently focused button
}

activateButton(button) { ; Define function
    global appName
    ; Do something when a given button is activated, like
    msgBox button.label, appName ; Dysplay a standard AHK message box with the label of the button
}
```
### Translating Overlays
By calling the "translate" metod of an accessibilityOverlay object it's possible to translate that object to different languages. The currently supported languages are English, Slovak and Swedish. Note that this method does not translate the user labels of the added elements - just predefined information mostly related to control type and state announcement.
To translate an accessibilityOverlay object, call the “translate” method once you have added all control elements to it and supply the desired language as a parameter like so:
```
overlay := accessibilityOverlay() ; Create a new overlay object
overlay.addHotspotButton("Button 1", 120, 180) ; Add a button that will get clicked at the coordinates specified once the button is activated
overlay.addHotspotButton("Button 2", 180, 180) ; Add a second button
overlay.translate("Slovak") ; Translate the overlay object to Slovak
overlay.translate("Swedish") ; Translate the overlay object to Swedish
overlay.translate("English") ; Translate the overlay object back to English
```
### Resetting Overlays
The "reset" method resets a given accessibilityOverlay object to its initial state. This means that the overlay is going to behave as if you had launched a fresh instance of your script.
To reset an accessibilityOverlay, create an overlay object and call the "reset" method when needed:
```
overlay := accessibilityOverlay() ; Create a new overlay object
overlay.addHotspotButton("Button 1", 120, 180) ; Add a button that will get clicked at the coordinates specified once the button is activated
overlay.addHotspotButton("Button 2", 180, 180) ; Add a second button
overlay.reset() ; Reset the overlay object to its initial state
```
## Defined Classes
Here is a list of all currently defined classes:
* accessibilityOverlay - Creates an overlay object that can serve as a container for other controls.
* customControl - Creates a completely custom control that does absolutely nothing on its own (instead it relies on the 2 extra functions specified).
* customButton - Creates a button that only requires a label and the names of functions to be executed up on focus and/or activation.
* hotspotButton - Creates a button that clicks the mouse coordinates specified up on activation and optionally triggers extra functions up on focus and/or activation.
* graphicButton - Creates a button that looks for images, reports an error if the specified graphics can not be found and optionally triggers extra functions up on focus and/or activation.
* tabControl - Creates an element for attaching tabs on to.
* customTab - Creates a tab that only requires a label and the name of the function to be triggered up on focus.
* hotspotTab - Creates a tab that clicks the mouse coordinates specified and optionally triggers an extra function up on focus.
* graphicTab - Creates a tab that looks for images, reports an error if the specified graphics can not be found and optionally triggers an extra function up on focus.
