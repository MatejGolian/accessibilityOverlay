# What Is This?
This is a set of classes written in AutoHotkey 2 that makes it possible to simulate accessible user interface elements by combining AutoHotkey functionality with screen reader output. It was specifically written to address the needs of blind users who often require a large number of keyboard shortcuts when creating AHK-based accessibility solutions for otherwise inaccessible applications.
## Requirements
1. AutoHotkey version 2
2. JAWS, NVDA or Microsoft SAPI voices installed on your system
3. If you want to create controls based on OCR results, you will need the OCR library found [here](https://github.com/Descolada/OCR).
4. In case you want to use NVDA for speech output, you'll need a copy of the nvdaControllerClient DLL depending on your build of AutoHotkey. The nvdaControllerClient DLL is available both in 32 and 64-bit and both versions can be downloaded at the following location: http://www.Nvda-project.Org/nvdaControllerClient/nvdaControllerClient_20100219.7z
   * Use nvdaControllerClient32.Dll with the 32-bit version of AutoHotkey.
   * Use nvdaControllerClient64.Dll with the 64-bit version of AutoHotkey.
## How It Works
You define elements using the classes found in the "AccessibilityOverlay.ahk" file. These elements then get automatically voiced either by JAWS, NVDA or Microsoft SAPI.
* If JAWS is running, the elements are automatically voiced using JAWS.
* If NVDA is running and if the appropriate copy of the nvdaControllerClient DLL is located in your script directory, the elements are automatically voiced using NVDA.
* If nor JAWS or NVDA is running or if the appropriate copy of the nvdaControllerClient DLL can not be found in your script directory, the elements are automatically voiced using Microsoft SAPI. Note that when both JAWS and NVDA are available, they will both be used for output.
### Basic Usage Example
```
#Requires AutoHotkey v2.0

#Include AccessibilityOverlay.ahk ; Include the overlay classes in the script
#Include OCR.ahk ; Support OCR

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
If so desired, a single object can trigger more than one function on focus or activation. For it to do so, pass an array of functions on to it during instantiation.
Here is how to create an overlay with buttons that fire user defined functions:
```
#Requires AutoHotkey v2.0

#Include AccessibilityOverlay.ahk ; Include the overlay classes in the script
#Include OCR.ahk ; Support OCR

AppName := "My App"

AccessibilityOverlay.Speak(AppName . " ready") ; Make NVDA or SAPI report that your script has been launched

Overlay := AccessibilityOverlay() ; Create a new overlay object
Overlay.AddHotspotButton("Button 1", 120, 180, FocusButton, ActivateButton) ; Add a button that will get clicked at the coordinates specified once it's activated and make it trigger the "focusButton" and "activateButton" functions
Overlay.AddHotspotButton("Button 2", 180, 180, [FocusButton, FocusButton2], [ActivateButton, ActivateButton2]) ; Add a second button that triggers 2 focus functions and 2 activate functions

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

FocusButton2(Button) { ; Define function
    Global AppName
    ; Do something when a given button receives focus, like
    MsgBox Button.Label, AppName ; Dysplay a standard AHK message box with the label of the currently focused button
}

ActivateButton(Button) { ; Define function
    Global AppName
    ; Do something when a given button is activated, like
    MsgBox Button.Label, AppName ; Dysplay a standard AHK message box with the label of the button
}

ActivateButton2(Button) { ; Define function
    Global AppName
    ; Do something when a given button is activated, like
    MsgBox Button.Label, AppName ; Dysplay a standard AHK message box with the label of the button
}
```
### Advanced Control Adding
You can use the methods "AddControl" and "AddControlAt" to add child controls to AccessibilityOverlays. The "AddControl" method adds a control as the last control, while "AddControlAt" inserts the control at the specified index pushing all later controls.
```
Overlay := AccessibilityOverlay() ; Create a new overlay object
Overlay.AddHotspotButton("Button 1", 120, 180) ; Add a button that will get clicked at the coordinates specified once the button is activated
Overlay.AddHotspotButton("Button 3", 180, 180) ; Add a button that will become the third button once all controls have been added
Overlay.AddControl(HotspotButton("Button 4", 210, 180))  ; Add a button that will become the fourth button once all controls have been added
Overlay.AddControlAt(2, HotspotButton("Button 2", 150, 180)) ; Add this as the second button
```
### Removing Controls From An Overlay
The methods "Remove" and "RemoveAt" can be used to remove child controls from AccessibilityOverlay objects. The "Remove" method always removes the last control, while "RemoveAt" removes the control at the specified index.
```
Overlay := AccessibilityOverlay() ; Create a new overlay object
Overlay.AddHotspotButton("Button 1", 120, 180) ; Add a button that will get clicked at the coordinates specified once the button is activated
Overlay.AddHotspotButton("Button 2", 180, 180) ; Add a second button
Overlay.AddHotspotButton("Button 3", 180, 180) ; Add a third button
Overlay.Remove() ; Remove the third button
Overlay.RemoveAt(1) ; Remove the first button
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
* CustomControl - Creates a completely custom control that does absolutely nothing on its own (instead it relies on the custom functions specified).
* CustomButton - Creates a button that only requires a label and the functions to be executed up on focus and/or activation.
* HotspotButton - Creates a button that clicks the mouse coordinates specified up on activation and optionally triggers extra functions up on focus and/or activation.
* GraphicalButton - Creates a button that looks for images, reports an error if the specified graphics can not be found and optionally triggers extra functions up on focus and/or activation.
* OCRButton - Creates a button that OCRs a portion of the screen up on focus and automatically updates its label with the result.
* GraphicalCheckbox - Creates a checkbox that looks for images, reports an error if the specified graphics can not be found and optionally triggers extra functions up on focus and/or activation.
* CustomComboBox - Creates a combo box announcement and executes functions up on focus.
* HotspotComboBox - Creates a combo box announcement, clicks the mouse coordinates specified up on focus and optionally triggers extra functions up on focus.
* OCRComboBox - Creates a combo box announcement, OCRs a portion of the screen up on focus and treats the result as its value.
* CustomEdit - Creates a edit field announcement and executes functions up on focus.
* HotspotEdit - Creates a edit field announcement, clicks the mouse coordinates specified up on focus and optionally triggers extra functions up on focus.
* OCREdit - Creates an edit field announcement, OCRs a portion of the screen up on focus and treats the result as its value.
* OCRText - OCRs a portion of the screen up on focus and announces the result.
* StaticText - Announces a simple message.
* TabControl - Creates an element for attaching tabs on to.
* CustomTab - Creates a tab that only requires a label and an optional function to be triggered up on focus.
* HotspotTab - Creates a tab that clicks the mouse coordinates specified and optionally triggers extra functions up on focus.
* GraphicalTab - Creates a tab that looks for images, reports an error if the specified graphics can not be found and optionally triggers extra functions up on focus.
* OCRTab - Creates a tab announcement, OCRs a portion of the screen up on focus and automatically updates its label with the result.
