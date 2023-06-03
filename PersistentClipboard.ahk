#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, off
#include libraries\3rdparty\ini.ahk
formattime, Year,, yyyy ;
formattime, Date,, dd-MM-%year%
FileCreateDir, %A_appdata%\DewrDev\PersistentClipboard
global LogDir:= A_appdata "\DewrDev\PersistentClipboard\" Date ".log"
global ConfigDir:= A_appdata "\DewrDev\PersistentClipboard\Config.ini"
global DataDir:= A_appdata "\DewrDev\PersistentClipboard\Data.ini"
global StringsDir:= A_appdata "\DewrDev\PersistentClipboard\Strings.ini"
file=array()
strings:= new ini(StringsDir)
global GuiHwnd=
global pastecount

global flipit=1
global flipem=0
global Edits=0
global runonce=0

global ScriptTitle="Persistent Clipboard"
global TabTitle="Create Issue - Jira"
guiWidth=300
groupboxwidth:= guiWidth +1
AddBoxBtnWidth:= groupboxwidth - 25

gui, Main:new, -MaximizeBox -Minimizebox +resize +MaxSize%guiWidth%x +MinSize%guiWidth%x +HwndGuiHwnd
gui, Main:add, button,x0 y0 w%guiWidth% gConfigure vConfigBtn, Configure
Gui, Main:Add, ListView,vscroll y+0 vList h350 w%groupboxwidth% -Multi readonly gListFunc AltSubmit, Clipboards|Paste Count


; LV_ModifyCol() 

configure()
Gui, Main:Default
FileRead, StringsFile, %Stringsdir%
loop, % strings.sections().length()
{
    string:=strings.get("text","string" A_Index,"")
    string:= StrReplace(string, "/~\" , "`n",,-1)
    count:=strings.get("pastecount","string" A_Index,"")
    LV_Add(,string, count)
    Edits:= ++Edits
    ; msgbox, Edit%edits%
    gui, config:add, edit,vEdit%Edits% w%guiWidth%,%string%
    ; if (strlen(A_LoopField) != 1){
    ;     ; ColdLoads()
    ; }
}
; gui, main:show

; if (FileExist(Stringsdir) && Stringarr !=){
;     loop, Stringarr.Length() 
;     {
;         LV_Add(,, 0)
;         pastecount:= pastecount++

;     }
; }

; LV_Add(, "Expected:`n`nActual:`n`nRepro - ", 0)
; LV_Add(, "Launch the content from the terminal menu", 0)
; LV_Add(, "Afternoon all, `nTesting is now complete for ", 0)
LV_ModifyCol(2, "75 Integer")
LV_ModifyCol(1, "225 Text")

; gui, 1:add, groupbox, vscroll w%groupboxwidth% h500, stuffs

; gui, 1:add, edit,xp+5 yp+15
; gui, 1: add, button,xp yp+25 w%AddBoxBtnWidth%, Add Box

SetTitleMatchMode, RegEx

gui, main:show,h350 w%guiWidth% NoActivate ,%ScriptTitle%

loop, {
    writelog("[SCRIPT] - Waiting for window: " TabTitle)
    WinWaitActive, %TabTitle%
    WinGetActiveTitle, ActiveWin
    writelog("[ACTIVE WINDOW] - Should be Chrome: " ActiveWin)
    gui, main:show,h350 w%guiWidth% NoActivate ,%ScriptTitle%
    winset, alwaysontop,on, ahK_id%GuiHwnd%
    winset, top,, ahK_id%GuiHwnd%
    WinGetActiveTitle, ActiveWin
    writelog("[SCRIPT] - Running Active Window loop " ActiveWin)
    loop {
        WinGetActiveTitle, ActiveWin
        writelog(Activewin)
        WinWaitNotActive,%Tabtitle%|%ScriptTitle%
        writelog("[SCRIPT] - Destroying GUI. Active window is: " ActiveWin)
        WinGetPos, X, Y,, Height, %ScriptTitle%
        gui, minimize
        break
    }
}

return

ListFunc(){
    if (A_GuiEvent = "A"){
        LV_GetText(RowText, A_EventInfo)  ; Get the text from the row's first field.
        ; LV_GetText(IncrementPaste, A_EventInfo,2)
        ; A_EventInfo
        WinActivate,%Tabtitle%
        sendraw, %RowText%`n

        ; ToolTip You double-clicked row number %A_EventInfo%. Text: "%RowText%"
    }
}

Configure(){
    if (runonce=0){
        gui, Config: new,MinimizeBox -border -Maximizebox +parentMain,
        ; gui, Config:add, text,, oh hi there
        runonce=1
        return
    }
    ; gui, config:destroy
    flipfloop := {1: "Hide", 0: "Show"}
    guicontrol, % flipfloop[flipit], List
    EditLoopCount=0

    flipit:= !flipit
    flipem:= !flipem

    WinGetPos, , , Width, Height, %ScriptTitle%
    gui, Config:show, h%Height% w%Width% x-10 y+15,

    ; loop, Edits {
    ; EditLoopCount:= ++EditLoopCount
    ; msgbox, 
    ; guicontrol, % flipfloop[flipit], Edit%EditLoopCount%
    ; }
    ; loop, %pastecount% {

    ; }
}

SaveConfig(){
    IniWrite, Value, %DataDir%, Default, PasteCounts
}

WriteConfig(){
        WinGetPos, X, Y,, Height, %ScriptTitle%
        IniWrite, %Y%, %ConfigDir%, Windimensions, XPos
        IniWrite, %Y%, %ConfigDir%, Windimensions, YPos
        IniWrite, %Height%, %ConfigDir%, Windimensions, Height
        FileAppend
}

insert::
WinGetActiveTitle, OwO
Tabtitle:= OwO
    gui, main:show,h350 w%guiWidth% NoActivate ,%ScriptTitle%
    winset, alwaysontop,, ahK_id%GuiHwnd%
    winset, top,, ahK_id%GuiHwnd%
return

WriteLog(LogText){
    formattime, TimeNow,, HH:mm:ss:%A_msec% ;
    FileAppend,`n[%TimeNow%] - %LogText%, %LogDir%
}

~^!R::
Reload
return