#Requires AutoHotkey v2.0

#MaxThreadsPerHotkey 1
#NoTrayIcon
#SingleInstance Force
#Warn All
CoordMode "Caret", "Client"
CoordMode "Menu", "Client"
CoordMode "Mouse", "Client"
CoordMode "Pixel", "Client"
CoordMode "ToolTip", "Client"
SendMode "Input"
SetTitleMatchMode "RegEx"

#Include <Editor>

Editor.Show()

#HotIf WinActive("Overlay Editor ahk_class AutoHotkeyGUI")

^C::Editor.ItemCopyHK()
^V::Editor.ItemPasteHK()
^X::Editor.ItemCutHK()
Delete::Editor.ItemDeleteHK()
Enter::Editor.ItemAddHK()
F2::Editor.ItemEditHK()
