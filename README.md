# About
 An AutoHotkey 2 script created for the needs of blind users that makes it possible to simulate accessible user interface elements.
## What You'll Need
1. AutoHotkey version 2
2. The NVDA screen reader or Microsoft SAPI voices installed on your system
3. In case you want to use NVDA for speech output, you'll need a copy of the nvdaControllerClient DLL depending on which build of AutoHotkey you want to use.
   * nvdaControllerClient32.dll for the 32-bit version of AutoHotkey
   * nvdaControllerClient64.dll  for the 64-bit version of AutoHotkey
   * Both files can be downloaded at the following location: http://www.nvda-project.org/nvdaControllerClient/nvdaControllerClient_20100219.7z
## How It Works
 You define elements using the classes in the "accessibilityOverlay.ahk" file. These elements then get automatically voiced either by NVDA or Microsoft SAPI.
* If NVDA is running and if the appropriate copy of the nvdaControllerClient DLL is located in your script directory, the elements are automatically voiced using NVDA.
* If NVDA is not running or if the appropriate copy of the nvdaControllerClient DLL can not be found in your script directory, the elements are automatically voiced using Microsoft SAPI.
### Basic Usage Example
```
#include accessibilityOverlay.ahk ; Include the overlay classes in the script

appName := "My App"

accessibilityOverlay.speak(appName . " ready") ; Make NVDA or SAPI report that your script has been launched

overlay := accessibilityOverlay() ; Create a new overlay object
overlay.addHotspotButton("Main button 1", 120, 180) ; Add a button that will get clicked at the coordinates specified once the button is activated
overlay.addHotspotButton("Main button 2", 180, 180) ; Add a second button
mainTabControl := overlay.addTabControl("Pages") ; Add a tab control to the overlay object labelled "Pages"
basicTab := hotspotTab("Basic", 900, 292) ; Create a new tab object that will get clicked at the coordinates specified once it's selected
basicTab.addHotspotButton("Basic button 1", 640, 404) ; Add a button to this tab
basicTab.addHotspotButton("Basic button 2", 716, 404) ; Add a second button
basicTab.addHotspotButton("Basic button 3", 790, 404) ; Add a third button
advancedTab := hotspotTab("Advanced", 1048, 292) ; Create a second tab object labelled "Advanced"
advancedTab.addHotspotButton("Advanced button 1", 640, 480) ; Add the first button to this tab
advancedTab.addHotspotButton("Advanced button 2", 716, 480) ; Add a second button
advancedTab.addHotspotButton("Advanced button 3", 790, 480) ; Add a third button
mainTabControl.addTabs(basicTab, advancedTab) ; Add the 2 previously created tabs to the tab control object we defined before

; Set up keyboard shortcuts and navigation (items wrap automatically)
tab::Overlay.focusNextControl() ; Move focus to the next control
+tab::Overlay.focusPreviousControl() ; Move focus to the previous control
right::Overlay.focusNextTab() ; If the current control is a tab control use the right arrow to focus the next tab
left::Overlay.focusPreviousTab() ; If the current control is a tab control use the left arrow to focus the previous tab
enter::Overlay.activateCurrentControl() ; Activate the currently focused control
ctrl::AccessibilityOverlay.stopSpeech() ; Stops SAPI (does not do anything in case of NVDA, since that's not needed)
```
### Firing Custom Functions
 When creating elements such as buttons and tabs, you can optionally supply the names of functions that will be executed either when the given control receives focus or once its activated. These 2 functions are always the 2 last parameters expected by the constructor method and once they get triggered, the calling object is automatically passed on to them as a parameter.
For instance, here is how to create an overlay with a button that fires user defined functions:
```
#include accessibilityOverlay.ahk ; Include the overlay classes in the script

appName := "My App"

accessibilityOverlay.speak(appName . " ready") ; Make NVDA or SAPI report that your script has been launched

overlay := accessibilityOverlay() ; Create a new overlay object
overlay.addHotspotButton("Main button 1", 120, 180, "focusButton", "activateButton") ; Add a button that will get clicked at the coordinates specified once the button is activated and make it trigger the "focusButton" and "activateButton" functions
overlay.addHotspotButton("Main button 2", 180, 180, "focusButton", "activateButton") ; Add a second button

return ; End auto-execute section

focusButton(button) {
    ; Do something when a given button receives focus, like
    msgBox(button.label) ; Dysplay a standard AHK message box with the label of the currently focused button
}

activateButton(button) {
    ; Do something when a given button is activated, like
    msgBox(button.label) ; Dysplay a standard AHK message box with the label of the button
}
```
## Defined Classes
* accessibilityOverlay - Creates an overlay object that can serve as a container for other controls.
* customControl - Creates a completely custom control that does absolutely nothing on its own (instead it relies on the 2 custom functions specified).
* customButton - Creates a button that only uses a label and 2 custom actions when it gets focused or activated.
* hotspotButton - Creates a button that clicks the mouse coordinates specified up on activation and optionally triggers custom functions.
* graphicButton - Creates a button that looks for images and reports an error if the specified graphics are not found.
* tabControl - Creates an element for attaching tabs on to.
* hotspotTab - Creates a tab that clicks the mouse coordinates specified up on focus and optionally triggers custom functions.
* graphicTab - Creates a tab that looks for images and reports an error if the specified graphics are not found.
