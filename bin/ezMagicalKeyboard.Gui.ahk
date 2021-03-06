﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
;#Persistent
#NoTrayIcon
#SingleInstance force
#WinActivateForce
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
SetMouseDelay, -1
SetWinDelay, -1

global UnsavedData := 0

global gSocket
global gConnected = 0
global gTick = 0
global gCustomFileName = 0

#Include %A_ScriptDir%\talk.ahk
#Include %A_ScriptDir%\Socket.ahk
#Include %A_ScriptDir%\ezMagicalKeyboard.Config.ahk
#Include %A_ScriptDir%\ezMagicalKeyboard.Form.ahk

KeyLogger := new talk("ezMagicalKeyboard.Logger")

OnExit, CloseProgram

If (sAutoConnect == "1") {
  GoSub, ConnectServer
}

Return

MainGuiClose:
  ExitApp
Return

OpenServerConfig:
  Gui, Config:+OwnerMain
  Gui, Config:Show
Return

testConnection:
  Gui, Config:Submit, NoHide
  GuiControl, Disable, ConfigGenetal

  tSocket := new TestSocket()

  tSocket.Connect([tServer, tPort += 0])
  tSocket.sendText("TEST")
Return

ConnectServer:
  UnSavedData := 1
  If (gConnected = 0)
  {
    gSocket := new ActionSocket()
    gSocket.Connect([sServer, sPort])
  }
  Else
  {
    gSocket.Disconnect()
  }
Return

ConfirmServerConfig:
  Gui, Config:Submit

  sServer := tServer
  sPort := tPort
  sType := tType
  sId := tId

  NewConfig := { "LAST_SERVER": sServer
               , "LAST_PORT":   sPort
               , "CLIENT_TYPE": sType
               , "CLIENT_ID":   sId }
  ModifyConfig(NewConfig)
  SaveConfig()

  GuiControl, Main:, gServer, %sServer%
  GuiControl, Main:, gPort, %sPort%
Return

CancelServerConfig:
  GuiControl, Config:, tServer, %sServer%
  GuiControl, Config:, tPort, %sPort%

  Gui, Config:Submit
Return

OpenLoggerConfig:
  Gui, LoggerOption:+OwnerMain
  Gui, LoggerOption:Show
Return

ConfirmLoggerConfig:
  Gui, LoggerOption:Submit

  sLoggerEnabled := tLoggerEnabled

  NewConfig := { "LOGGER_ENABLED": sLoggerEnabled }
  ModifyConfig(NewConfig)
  SaveConfig()
Return

CancelLoggerConfig:
  GuiControl, LoggerOption:, tLoggerEnabled, %sLoggerEnabled%

  Gui, LoggerOption:Submit
Return

CloseProgram:
  If (gConnected = 1)
    gSocket.Disconnect()
  
  If (UnsavedData == 1)
  {
    MsgBox, 35, Confirm, Unsaved data found, export your data before closing the program?
    IfMsgBox, Yes
    {
      GoSub, ExportFile
    }
    IfMsgBox, Cancel
    {
      Return
    }
  }

  KeyLogger.terminate()
ExitApp

ClearList:
  MsgBox, 52, Confirm, This action will clear all the data in the log list, are you sure?
  IfMsgBox, Yes
  {
    Gui, Main:Default
    LV_Delete()
  }
Return

ExportFile:
  Gui, Main:Default
  Gui, Main:ListView, LogList

  FormatTime, CurrentDate , , yy-MM-dd HH-mm-ss
  FileName := A_ScriptDir . "\data\" . (gCustomFileName == 0 ? CurrentDate : gCustomFileName) . ".csv" 
  gCustomFileName = 0

  IfExist, %FileName%
    FileDelete, %FileName%
  
  Header := "Time, Delay, Data`r`n"
  FileAppend, %Header%, %FileName%

  Loop % LV_GetCount() 
  {
    line := ""
    Row := A_Index
    Loop % LV_GetCount("Column") 
    {
      Col := A_Index
      LV_GetText(RetrievedText, Row, Col)
      If (Col <> 1)
      {
        line = %line%, %RetrievedText%
      }
      Else
      {
        line = %RetrievedText%
      }
    }

    Fileappend, %Line%`r`n, %FileName%
  }

  UnSavedData := 0
  MsgBox, 36, Confirm, The data have been successfully exported, open it?
  IfMsgBox, Yes
  {
    Run, %FileName%
  }
Return

SendLoggedKey:
  ;MsgBox, %loggedKey%

  If (gConnected == 1)
  {
      TickTime := A_TickCount - gTick
      Command := "KEY " loggedKey
      gSocket.sendText(Command)

      IconCommand := "Icon" IconIndex["KEYOUT"]

      Gui, Main:Default
      LV_Add(IconCommand, TickTime, "", "*" Command)
      LV_Modify(LV_GetCount(), "Vis")
      UnsavedData := 1
  }
Return

class TestSocket extends SocketTCP 
{
  onErrorConn() 
  {
    GuiControl, Config:Enable, ConfigGenetal

    MsgBox, 16, Error, Can't connect to the server!
  }

  onSent() 
  {
    GuiControl, Config:Enable, ConfigGenetal
    this.Disconnect()

    MsgBox, 64, Success, successfully connected to the server!
  }
}

class ActionSocket extends SocketTCP 
{
  onConnected()
  {
    gConnected := 1
    gTick := A_TickCount

    GuiControl, Main:, Status, ..\assets\connected.png
    GuiControl, Main:Disable, ConfigButton
    GuiControl, Main:, ConnectButton, &Disconnect
  }

  onDisConnected()
  {
    gConnected := 0

    GuiControl, Main:, Status, ..\assets\disconnected.png
    GuiControl, Main:Enable, ConfigButton
    GuiControl, Main:, ConnectButton, &Connect
  }

  simulatePress(Key, RecvTime)
  {
    SendInput, %Key%
    Return A_TickCount - RecvTime
  }

  onRecv()
  {
    RecvTime := A_TickCount
    TickTime := recvTime - gTick

    this.Buffer .= this.RecvText(,, "CP0")
    Lines := StrSplit(this.Buffer, "`n", "`r")
    this.Buffer := Lines.Pop()

    for Index, Line in Lines
    {
      VarSetCapacity(ConvBuf, StrPut(Line, "CP0"))
      StrPut(Line, &ConvBuf, "CP0")
      Command := StrGet(&ConvBuf, "UTF-8")

      If RegExMatch(Command, "^KEY ")
      {
        CommandType := "KEYIN"
        Key := StrSplit(Command, " ")[2]
        If RegExMatch(Key, "[a-z0-9]")
        {
          RT := this.simulatePress(Key, RecvTime)
        }
        Else
        {
          gSocket.sendText("!ENOTALLOWED")
        }
      }
      Else If RegExMatch(Command, "^(ST|EN|LK|UL|EX|RS|PING|PONG|WHO|VERIFIED|REGISTERED)$"){
        CommandType := Command
        RT := ""
      }
      Else If RegExMatch(Command, "^!")
      {
        CommandType := "ERROR"
        RT := ""
      }

      If (Command == "LK")
      {
        CommandType := "LK"
        Gui, Main:+AlwaysOnTop
        GuiControl, Main:Choose, MainTab, 2
      }
      Else If (Command == "UL")
      {
        CommandType := "UL"
        Gui, Main:-AlwaysOnTop
      }
      Else If RegExMatch(Command, "^EX$|^EX ")
      {
        CommandType := "EX"
        if RegExMatch(Command, "^EX ")
        {
          gCustomFileName := StrSplit(Command, "EX ")[2]
        }
        GoSub, ExportFile
      }
      Else If (Command == "RS")
      {
        If (gConnected = 1)
          gSocket.Disconnect()
        Reload
      }
      Else If (Command == "PING")
      {
        gSocket.sendText("PONG")
      }
      Else If (Command == "WHO")
      {
        TypeString := "TP " . sType
        gSocket.sendText(TypeString)
      }
      Else If (Command == "VERIFIED")
      {
        If (sId != "")
        {
          IdString := "ID " . sId
          gSocket.sendText(IdString)
        }
      }

      Gui, Main:Default

      ThisIcon := IconIndex[CommandType]
      IconCommand = Icon%ThisIcon%
      LV_Add(IconCommand, TickTime, RT, Command)
      LV_Modify(LV_GetCount(), "Vis")
      UnsavedData := 1
    }
  }

  onErrorConn()
  {
    MsgBox, 16, Error, Can't connect to the server!
  }
}