'SeedRnd(MilliSecs())

'MAIN SETTINGS'
Global ini:TPertIni = TPertIni.Create("config.ini") 
ini.Load() 
Global oBombLose:Byte = Byte(iniloaddef("settings", "Bombkill", 1)) 
Global oPan:Byte = Byte(iniloaddef("settings", "Pan", 1)) 
Global oInverted:Byte = Byte(iniloaddef("settings", "InvertArrows", 0)) 
Global oWidth:Int = Int(iniloaddef("minefield", "Width", 9))
Global oHeight:Int = Int(iniloaddef("minefield", "Height", 9))
Global oMines:Int = Int(iniloaddef("minefield", "Mines", 10))
Global oWrap:Byte = Byte(iniloaddef("minefield", "Wrap", 1))
Global oSound:Byte = Byte(iniloaddef("settings", "Sound", 1))
Global oEffects:Byte = Byte(iniloaddef("settings", "Effects", 1))
Global oPort:String = iniloaddef("network", "ServerPort", 8200)
Global oIP:String = iniloaddef("network", "ServerIP", "192.168.0.1")
Global oName:String = iniloaddef("network", "Name", Chr(Rand(Asc("a"), Asc("z"))) + "Player" + Chr(Rand(Asc("a"), Asc("z"))) + Chr(Rand(Asc("a"), Asc("z")))) 

Global oListPort:String = iniloaddef("network", "ServerListPort", "8201")
Global oListIP:String = iniloaddef("network", "ServerListIP", "spacerat.no-ip.biz")
ini.Save(1)

Rem
'TWEAKSETTINGS'
Global sini:TPertIni = TPerIni.Create("app.ini") 
sini.Load() 

Global stRevBlockAlpha:Float = siniloaddef("blocks","RevBlockAlpha","0.78") 
endrem




Function IniLoadDef:String(section:String, key:String, def:String) 
	If ini.GetSection(section) = Null
		ini.AddSection(section) 
		ini.SetSectionValue(section, key, def) 
	ElseIf ini.GetSectionValue(section, key) = Null
		ini.SetSectionValue(section, key, def) 
	EndIf
	Return ini.GetSectionValue(section, key) 
End Function