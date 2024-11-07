#Requires AutoHotkey v2.0

#MaxThreadsPerHotkey 1
#SingleInstance Force
#Warn All
CoordMode "Caret", "Client"
CoordMode "Menu", "Client"
CoordMode "Mouse", "Client"
CoordMode "Pixel", "Client"
CoordMode "ToolTip", "Client"
SendMode "Input"
SetTitleMatchMode "RegEx"

#Include <AccessibilityOverlay>
#Include <Editor>

Editor.Show()
