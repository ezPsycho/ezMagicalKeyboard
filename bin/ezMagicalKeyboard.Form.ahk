global LogListIconSrc := ["Default", "ST", "EN", "KEYIN", "KEYOUT", "RUN", "LK", "UL", "EX", "ER", "PING", "WHO", "RS", "VERIFIED", "ERROR"]
global IconIndex := {"ST": 2, "EN": 3, "KEYIN": 4, "KEYOUT": 5, "RUN": 6, "LK": 7, "UL": 8, "EX": 9, "ER": 10, "PING": 11, "WHO": 12, "RS": 13, "VERIFIED": 14, "REGISTERED": 14, "ERROR": 15}

Menu, Tray, Icon, ..\assets\Icon.ico

Gui, Main: New, -MaximizeBox +MinSize546x, ezMagicalKeyboard
Gui, Font, s8 w500, Segoe UI
Gui, Add, Tab3, vMainTab, General|Log|About

Gui, Add, Picture, w36 h36 vStatus, ..\assets\disconnected.png
Gui, Add, Text   , xp+50  yp+2 w310, ezMagicalKeyboard uses the following information to connect your LabNirs with the experiment server.
Gui, Add, Text   , xp-50  yp+45, Server:
Gui, Add, Text   , xp     yp+20, Port:
Gui, Add, Text   , xp+50  yp-20 w100 vgServer, %sServer%
Gui, Add, Text   , xp     yp+20 w100 vgPort, %sPort%
Gui, Add, Text   , xp-50  yp+30, To change the experiment server you want to `nconnect to, click Server Config.
Gui, Add, Text   , xp     yp+40, To connect to the experiment and start auto `ntriggering, click Connect.
Gui, Add, Button , xp+250 yp-35 w120 h20 gOpenServerConfig vConfigButton, &Server Config
Gui, Add, Button , xp     yp+40 w120 h20 gConnectServer vConnectButton, &Connect

Gui, Add, Picture, xp-250 yp+50 w36 h36 vProgramIcon, ..\assets\program.png
Gui, Add, Text   , xp+50  yp+2 w310, Additional configuration options are listed below, you can modify the options to fit your experiment design.
Gui, Add, Text   , xp-50  yp+45, To modify the options of keyboard logger, click`nKey Logger.
Gui, Add, Button , xp+250 yp+5 w120 h20 gOpenLoggerConfig vLoggerButton, &Key Logger


Gui, Tab, 2
Gui, Add, ListView, vLogList w370 h300 0x2, Time|Delay|Data
Gui, Add, Button  , xp+270 yp+310 w100 gExportFile, &Export
Gui, Add, Button  , xp-110 yp     w100 gClearList, &Clear

Gui, Tab, 3
Gui, Add, Picture, x20 y25  w370 h93, ..\assets\logo.png
Gui, Add, text   , x20 y120 w375 0x10
Gui, Add, Picture,        yp+10 w36 h36, ..\assets\icon.png
Gui, Add, Text   , xp+45  yp-2  , ezMagicalKeyboard (Beta 1.3.0)
Gui, Add, Text   , xp     yp+17 , Cpoyright 2017 Losses Territory Studio.
Gui, Add, Text   , xp     yp+17 w310, This program is free software: you can redistribute it and/or modify it under the terms of the MIT License.
;Gui, Add, Text   , xp     yp+17 , This program is free software: you can redistribute it and/or modify `nit under the terms of the GNU General Public License as published `nby the Free Software Foundation, either version 3 of the License, or `n(at your option) any later version.
Gui, Add, Link,    xp     yp+50 w310, The icon of this program is made by <a href="https://orioniconlibrary.com">Orion Icon Library</a>, the other icons in this program are from <a href="https://icons8.com/">Icons8</a>, the socket library by <a href="https://github.com/G33kDude/Socket.ahk">G33kDude</a>, and talk library by <a href="https://github.com/aviaryan">Avi Aryan</a>, thanks for their generous and outstanding work.
Gui, Add, Text   , xp     yp+80 w310, NOTICE: All the artwork in this program was under their own license but not MIT, check their own website to know more about that.

IconCount := LogListIconSrc.MaxIndex()
LogListIcons := IL_Create(IconCount)
LV_SetImageList(LogListIcons)

Loop %IconCount% {
  ThisIconName := LogListIconSrc[A_Index]
  ThisFileName = ..\assets\%ThisIconName%.png
  IL_Add(LogListIcons, ThisFileName)
}

LV_ModifyCol(1, "80")
LV_ModifyCol(2, "70")
LV_ModifyCol(3, "170")

Gui, Config: New, -MaximizeBox -MinimizeBox +MinSize546x, ezMagicalKeyboard
Gui, Font, s8, Segoe UI
Gui, Add, Tab3    , vConfigGenetal, General|Integration
Gui, Add, Text    , xp+15  yp+30 , You can set your server information in this page, to confirm if the `nserver is available, click Test Connection.
Gui, Add, GroupBox, xp     yp+45 w410 h130, Server Information:
Gui, Add, Text    , xp+10  yp+30, Server &address:
Gui, Add, Text    , xp     yp+27, Server &port:
Gui, Add, Edit    , xp+150 yp-33 w220 vtServer, %sServer%
Gui, Add, Edit    , xp     yp+27 w220 vtPort  , %sPort%
Gui, Add, Button  , xp+110 yp+40 w120 gTestConnection vTestButton, &Test Connection
Gui, Tab, 2
Gui, Add, Text    , xp-270 yp-136, You can set how the client integrate into ezTrigger system. Please try to avoid `nmodifying the contents of this tab, otherwise you may not be able to connect`nto the ezTrigger server properly.
Gui, Add, GroupBox, xp     yp+60  w410 h125, ezTrigger Integration:
Gui, Add, Text    , xp+10  yp+30, Client &type:
Gui, Add, Text    , xp     yp+27, Client &id:
Gui, Add, Edit    , xp+150 yp-33 w220 vtType, %sType%
Gui, Add, Edit    , xp     yp+27 w220 vtId  , %sId%
Gui, Tab
Gui, Add, Button  , x300     w70 gConfirmServerConfig, OK
Gui, Add, Button  , xp+80 yp w70 gCancelServerConfig, Cancel

Gui, LoggerOption: New, -MaximizeBox -MinimizeBox +MinSize546x, ezMagicalKeyboard
Gui, Font, s8, Segoe UI
Gui, Add, Tab3    , vConfigGenetal, General
Gui, Add, Text    , xp+15  yp+30, You can set the options about keyboard logger here, the keyboard logger will send your`nkey press to remote server, please note that only a-z, 0-9 will be sent for secutiry concern.
Gui, Add, GroupBox, xp     yp+45 w410 h130, Keyboard Logger:

Gui, Add, Checkbox, xp+10  yp+30 Checked%sLoggerEnabled% vtLoggerEnabled, Enable the keyboard logger

Gui, Tab
Gui, Add, Button  , x300     w70 gConfirmLoggerConfig, OK
Gui, Add, Button  , xp+80 yp w70 gCancelLoggerConfig, Cancel

Gui, Main:Show