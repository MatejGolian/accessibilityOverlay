# What Is This?
This is a set of classes written in AutoHotkey 2 that makes it possible to simulate accessible user interface elements by combining AutoHotkey functionality with screen reader output. It was specifically written to address the needs of blind users who often require a large number of keyboard shortcuts when creating AHK-based accessibility solutions for otherwise inaccessible applications.
## Requirements
1. AutoHotkey version 2
2. The NVDA screen reader or Microsoft SAPI voices installed on your system
3. In case you want to use NVDA for speech output, you'll need a copy of the nvdaControllerClient DLL depending on your build of AutoHotkey. The nvdaControllerClient DLL is available both in 32 and 64-bit and both versions can be downloaded at the following location: http://www.Nvda-project.Org/nvdaControllerClient/nvdaControllerClient_20100219.7z
   * Use nvdaControllerClient32.Dll with the 32-bit version of AutoHotkey.
   * Use nvdaControllerClient64.Dll with the 64-bit version of AutoHotkey.
## How It Works
You define elements using the classes found in the "AccessibilityOverlay.Class.ahk" file. These elements then get automatically voiced either by NVDA or Microsoft SAPI.
* If NVDA is running and if the appropriate copy of the nvdaControllerClient DLL is located in your script directory, the elements are automatically voiced using NVDA.
* If NVDA is not running or if the appropriate copy of the nvdaControllerClient DLL can not be found in your script directory, the elements are automatically voiced using Microsoft SAPI.
### Basic Usage Example
```
#Requires AutoHotkey v2.0

#Include AccessibilityOverlay.Class.ahk ; Include the overlay classes in the script

AppName := "My App"

AccessibilityOverlay.Speak(AppName . " ready") ; Make NVDA or SAPI report that your script has been launched

overlay := AccessibilityOverlay() ; Create a new overlay object
Overlay.AddHotspotButton("Main button 1", 120, 180) ; Add a button that will get clicked at the coordinates specified once it's activated
Overlay.AddHotspotButton("Main button 2", 180, 180) ; Add a second button
MainTabControl := overlay.AddTabControl("Pages") ; Add a tab control to the overlay object and label it "Pages"
BasicTab := HotspotTab("Basic", 900, 292) ; Create a new tab object that will get clicked at the coordinates specified once it's selected
BasicTab.AddHotspotButton("Basic button 1", 640, 404) ; Add a button to this tab
BasicTab.AddHotspotButton("Basic button 2", 716, 404) ; Add a second button
BasicTab.AddHotspotButton("Basic button 3", 790, 404) ; Add a third button
AdvancedTab := HotspotTab("Advanced", 1048, 292) ; Create a second tab object labelled "Advanced"
AdvancedTab.AddHotspotButton("Advanced button 1", 640, 480) ; Add the first button to this tab
AdvancedTab.AddHotspotButton("Advanced button 2", 716, 480) ; Add a second button
AdvancedTab.AddHotspotButton("Advanced button 3", 790, 480) ; Add a third button
MainTabControl.AddTabs(BasicTab, AdvancedTab) ; Add the 2 previously created tabs to the tab control object we defined before

#HotIf WinActive("ahk_exe notepad.Exe") ; Restrict the script to Notepad

; Set up keyboard shortcuts and navigation (items wrap automatically)
Tab::Overlay.FocusNextControl() ; Move focus to the next control
+Tab::Overlay.FocusPreviousControl() ; Move focus to the previous control
Right::Overlay.FocusNextTab() ; If the current control is a tab control use the right arrow to focus the next tab
Left::Overlay.FocusPreviousTab() ; If the current control is a tab control use the left arrow to focus the previous tab
Enter::Overlay.ActivateCurrentControl() ; Activate the currently focused control
Ctrl::AccessibilityOverlay.StopSpeech() ; Stops SAPI (does not do anything in case of NVDA, since that's not needed)

^R:: { ; Resets the overlay
    Global AppName, Overlay
    Overlay.Reset()
    AccessibilityOverlay.Speak(AppName . " reset")
}
```
### Firing Extra/Custom Functions
When creating elements such as buttons and tabs, you can optionally supply functions that will be executed either after the given control receives focus or once its activated. These functions are always the last parameters expected by the constructors and the calling object is automatically passed on to them as a parameter. Tab objects only support firing functions on focus, while buttons support firing functions on activation as well.
For instance, here is how to create an overlay with buttons that fire user defined functions:
```
#Requires AutoHotkey v2.0

#Include AccessibilityOverlay.Class.ahk ; Include the overlay classes in the script

AppName := "My App"

AccessibilityOverlay.Speak(AppName . " ready") ; Make NVDA or SAPI report that your script has been launched

Overlay := AccessibilityOverlay() ; Create a new overlay object
Overlay.AddHotspotButton("Button 1", 120, 180, FocusButton, ActivateButton) ; Add a button that will get clicked at the coordinates specified once it's activated and make it trigger the "focusButton" and "activateButton" functions
Overlay.AddHotspotButton("Button 2", 180, 180, FocusButton, ActivateButton) ; Add a second button

#HotIf WinActive("ahk_exe notepad.Exe") ; Restrict the script to Notepad

; Set up keyboard shortcuts and navigation (items wrap automatically)
Tab::Overlay.FocusNextControl() ; Move focus to the next control
+Tab::Overlay.FocusPreviousControl() ; Move focus to the previous control
Right::Overlay.FocusNextTab() ; If the current control is a tab control use the right arrow to focus the next tab
Left::Overlay.FocusPreviousTab() ; If the current control is a tab control use the left arrow to focus the previous tab
Enter::Overlay.ActivateCurrentControl() ; Activate the currently focused control
Ctrl::AccessibilityOverlay.StopSpeech() ; Stops SAPI (does not do anything in case of NVDA, since that's not needed)

^R:: { ; Resets the overlay
    global AppName, Overlay
    overlay.Reset()
    AccessibilityOverlay.Speak(AppName . " reset")
}

FocusButton(Button) { ; Define function
    Global AppName
    ; Do something when a given button receives focus, like
    MsgBox Button.Label, AppName ; Dysplay a standard AHK message box with the label of the currently focused button
}

ActivateButton(Button) { ; Define function
    Global AppName
    ; Do something when a given button is activated, like
    MsgBox Button.Label, AppName ; Dysplay a standard AHK message box with the label of the button
}
```
### Translating Overlays
By calling the "Translate" metod of an AccessibilityOverlay object it's possible to translate that object to different languages. The currently supported languages are English, Slovak and Swedish. Note that this method does not translate the user labels of the added elements - just predefined information mostly related to control type and state announcement.
To translate an AccessibilityOverlay object, call the “Translate” method once you have added all control elements to it and supply the desired language as a parameter like so:
```
Overlay := AccessibilityOverlay() ; Create a new overlay object
Overlay.AddHotspotButton("Button 1", 120, 180) ; Add a button that will get clicked at the coordinates specified once the button is activated
Overlay.AddHotspotButton("Button 2", 180, 180) ; Add a second button
Overlay.Translate("Slovak") ; Translate the overlay object to Slovak
Overlay.Translate("Swedish") ; Translate the overlay object to Swedish
Overlay.Translate("English") ; Translate the overlay object back to English
```
### Resetting Overlays
The "Reset" method resets a given AccessibilityOverlay object to its initial state. This means that the overlay is going to behave as if you had launched a fresh instance of your script.
To reset an AccessibilityOverlay, create an overlay object and call the "Reset" method when needed:
```
Overlay := AccessibilityOverlay() ; Create a new overlay object
Overlay.AddHotspotButton("Button 1", 120, 180) ; Add a button that will get clicked at the coordinates specified once the button is activated
Overlay.AddHotspotButton("Button 2", 180, 180) ; Add a second button
Overlay.Reset() ; Reset the overlay object to its initial state
```
## Defined Classes
Here is a list of all currently defined classes:
* AccessibilityOverlay - Creates an overlay object that can serve as a container for other controls.
* CustomControl - Creates a completely custom control that does absolutely nothing on its own (instead it relies on the 2 extra functions specified).
* CustomButton - Creates a button that only requires a label and the functions to be executed up on focus and/or activation.
* HotspotButton - Creates a button that clicks the mouse coordinates specified up on activation and optionally triggers extra functions up on focus and/or activation.
* GraphicButton - Creates a button that looks for images, reports an error if the specified graphics can not be found and optionally triggers extra functions up on focus and/or activation.
* GraphicCheckbox - Creates a checkbox that looks for images, reports an error if the specified graphics can not be found and optionally triggers extra functions up on focus and/or activation.
* CustomEdit - Creates a edit field announcement and optionally executes a function up on focus.
* HotspotEdit - Creates a edit field announcement, clicks the mouse coordinates specified up on focus and optionally triggers an extra function up on focus
* TabControl - Creates an element for attaching tabs on to.
* CustomTab - Creates a tab that only requires a label and an optional function to be triggered up on focus.
* HotspotTab - Creates a tab that clicks the mouse coordinates specified and optionally triggers an extra function up on focus.
* GraphicTab - Creates a tab that looks for images, reports an error if the specified graphics can not be found and optionally triggers an extra function up on focus.
