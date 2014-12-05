Framework brl.blitz
Import brl.standardio
Import brl.Socket
Import brl.bankstream
Import brl.linkedlist
Import pub.threads
Import brl.retro

Function IniLoadDef:String(ini:TPertIni, section:String, Key:String, def:String)
	If ini.GetSection(section) = Null
		ini.AddSection(section) 
		ini.SetSectionValue(section, key, def) 
	ElseIf ini.GetSectionValue(section, key) = Null
		ini.SetSectionValue(section, key, def) 
	EndIf
	Return ini.GetSectionValue(section, key) 
End Function

Global INI:TPertIni = TPertIni.Create("globalserver.ini")
INI.Load()
Global MyIP:String = IniLoadDef(INI, "Server", "MyIP", "spacerat.no-ip.biz")

Function InpThreadF:Object(data:Object)
	Repeat
		Local i:String
		i = Input("")
		LockMutex(Mutex)
		inp = i
		UnlockMutex(Mutex)
	Forever
End Function

Function NetThreadF:Object(data:Object)
	If Not TCP.Bind(PORT) fail "---Failed to bind port"
	If Not SocketListen(TCP) fail "---Failed to set up listen socket"
	MPrint "---Socket init successful"
	Repeat
		If inp <> Null
			LockMutex(Mutex)
			Local il:String = inp
			inp = ""
			UnlockMutex(Mutex)
			
			Local i:String[] = il.Split(" ")
			Local ii:String = Lower(i[0])
			If ii = "stop" Or ii = "end" Or ii = "quit"
				LockMutex(Mutex)
				Stop = 1
				UnlockMutex(Mutex)
			ElseIf ii = "help"
				LockMutex(Mutex)
				Print "Global Server list by Spacerat."
				Print "Commands (case insensitive):"
				Print "stop/end/quit - Terminate the server."
				Print "help - Show help."
				UnlockMutex(Mutex)
			ElseIf ii = "listservers"
				For Local c:TNetClient = EachIn TNet.Clients
					If c.cType = 1
						If c.tcpsock.Connected() = 1
							MPrint c.name + "   " + DottedIP(c.IP) + "   " + String(c.PORT)
						Else
							c.Remove() 
						EndIf
					EndIf
				Next
			ElseIf ii = "chat"
				If i.dimensions()[0] > 1
					TNet.MNew(MES_CHAT)
					TNet.MLine(il[5..])
					For Local u:TNetClient = EachIn TNet.Clients
						If u.cType = 2
							TNet.MSend(u.tcpsock) 
						End If
					Next
					TNet.MClear()
				EndIf
			EndIf
			
			
		End If
		Local s:TSocket = SocketAccept(TCP)
		If s <> Null
			TNetClient.CreateClient(s) 
			DPrint "new connection"
		End If
		For Local cl:TNetClient = EachIn TNet.Clients
			If cl.cType < 1 and cl.cType > 2
				cl.timeout:-1
				If cl.timeout <= 0 cl.Remove() 
			endif
			If cl.tcpsock.Connected() = 0 Or cl = Null
				TNet.Clients.Remove(cl) 
				cl.tcpsock.Close() 
				DPrint "closed connection"
			Else
				If cl.tcpsock.ReadAvail() > 0
					Local mes:TBankStream = TNet.Recieve(cl.tcpsock, cl.tcpsock.ReadAvail())
					While Not mes.Eof() 
						If mes.ReadDouble() = MESNEWMESSAGE
							Local mesid:Short = mes.ReadShort() 
							Select mesid
								Case MES_SETTYPE
									Local t:Byte = mes.ReadByte() 
									If t = 1
										cl.cType = 1
										cl.Name = mes.ReadLine() 
										cl.PORT=mes.ReadInt()
										MPrint "New Game: " + cl.name
										For Local cc:TNetClient = EachIn TNet.Clients
											If cc.cType = 2 SendGames(cc.tcpsock) 
										Next
									ElseIf t = 2
										cl.cType = 2
										DPrint "New client"
									Else
										cl.Remove() 
									EndIf
								Case MES_GAMESTARTED
									If cl.cType = 1
										cl.Started = 1
										For Local ccc:TNetClient = EachIn TNet.Clients
											If ccc.cType = 2 SendGames(ccc.tcpsock) 
										Next
									End If
								Case MES_CHAT
									Local line:String = mes.ReadLine() 
									TNet.MNew(MES_CHAT) 
									TNet.MLine(line) 
									For Local clc:TNetClient = EachIn TNet.Clients
										If clc.cType = 2
											TNet.MSend(clc.tcpsock)
										End If
									Next
									MPrint "Chat|   " + line
									TNet.MClear() 
								Case MES_REFRESH
									SendGames(cl.tcpsock) 
									DPrint "sent games to client"
							End Select
						EndIf
					WEnd
				EndIf
			EndIf
		Next
		Delay 5
	Forever
EndFunction

Function SendGames(sock:TSocket) 
	Local l:TList = New TList
	For Local c:TNetClient = EachIn TNet.Clients
		If c.cType = 1
			If c.tcpsock.Connected() = 1
				 l.AddLast(c) 
			Else
				c.Remove() 
			EndIf
		EndIf
	Next
	TNet.MNew(MES_SENDGAMES)  
	TNet.Mshort(l.Count())
	For Local g:TNetClient = EachIn l
			If DottedIP(g.IP) = "127.0.0.1" TNet.MLine(MyIP) Else TNet.MLine(DottedIP(g.IP))
		'	TNet.MLine(DottedIP(g.IP))
			TNet.MInt(g.PORT)
			TNet.MShort(g.num) 
			TNet.MLine(g.name)
	Next
	TNet.MSend(sock) 
	TNet.MClear() 
End Function
Function fail(s:String) 
	MPrint "---Error: " + s
	'WaitThread(NetThread)
	'WaitThread(InpThread)
	Input "press any key to exit"
	Stop = 1
End Function

Function MPrint(s:String)
	LockMutex(Mutex)
	Print s
	UnlockMutex(Mutex)
End Function

Function DPrint(s:String)
	?debug
	LockMutex(Mutex)
	Print s
	UnlockMutex(Mutex)
	?
End Function

'''''''''MAIN LOOP''''''''''''''
Const MESNEWMESSAGE:Double = 68740
Const MES_SETTYPE:Short = 100
Const MES_REFRESH:Short = 101
Const MES_SENDGAMES:Short = 102
Const MES_CHAT:Short = 5
Const MES_GAMESTARTED:Short = 11

Const PORT = 8201
Global TCP:TSocket = New TSocket.CreateTCP()
Global gamenum:Short = 0
'''THREADING
Global NetThread:Int = CreateThread(NetThreadF, Null)
Global InpThread:Int = CreateThread(InpThreadF, Null)
Global Mutex:Int = CreateMutex()
Global inp:String
Global Stop = 0
'''
Repeat
Delay 10
Until Stop = 1
''''''''''''''''''''''''''''


Type TNet
	Global Bank:TBank = New TBank
	Global Message:TBankStream = CreateBankStream(Bank) 
	Global Clients:TList = New TList
	Function MClear() 
		Message.Close() 
		Bank = New TBank
		Message = CreateBankStream(bank) 
	End Function
	Function MClientSendTCP(exclude:TNetClient = Null) 
		For Local i:TNetClient = EachIn clients
			If Not (i = exclude) 
				MSend(i.tcpsock) 
			EndIf
		Next
	End Function
	Function MNew(MessageType:Short) 
		Message.WriteDouble(MESNEWMESSAGE) 
		Message.WriteShort(MessageType) 
	End Function
	Function MSend(sock:TSocket) 
		sock.Send(Message._bank._buf, Message._bank._size) 
	End Function
	Function BSend(sock:TSocket, Buf:Byte Ptr, Count:Int) 
		sock.Send(Buf, Count) 
	End Function
	Function MByte(n:Byte) 
		Message.WriteByte(n) 
	End Function
	Function MDouble(n:Double) 
		
		Message.WriteDouble(n) 
	End Function
	Function MFloat(n:Float) 
		
		Message.WriteFloat(n:Float) 
	End Function
	Function MInt(n:Int) 
		
		Message.WriteInt(n) 
	End Function
	Function MLong(n:Long) 
		
		Message.WriteLong(n) 
	End Function
	Function MShort(n:Short) 
		
		Message.WriteShort(n) 
	End Function
	Function MLine(str:String) 
		
		Message.WriteLine(str) 
	End Function
	Function MObject(obj:Object) 
		
		Message.WriteObject(obj) 
	End Function
	Function MString(str:String) 
		
		Message.WriteString(str) 
	End Function
	Function Recieve:TBankStream(sock:TSocket, length:Int)    'Reads length bytes from sock into a new bank and returns a bankstream
		Local bank:TBankStream = CreateBankStream(Null) 
		Local Buf:Byte[length] 
		sock.Recv(Buf, length) 
		bank.Write(Buf, length) 
		bank.Seek(0) 
		Return bank
	End Function
End Type

Type TNetClient
	Field IP:Int, PORT:Int, tcpsock:TSocket, Name:String = "", timeout:Int = 100, cType:Byte = 0, Started:Byte = 0, num = 0
	Function CreateClient:TNetClient(sock:TSocket) 
		Local n:TNetClient = New TNetClient
		n.tcpsock = sock
		n.IP = sock.RemoteIp() 
		n.PORT = sock.RemotePort() 
		Return n
	EndFunction
	Method New() 
		TNet.clients.AddLast(Self) 
		For Local n:Short = 0 To 65535
			Local h:Byte = 0
			For Local c:TNetClient = EachIn TNet.Clients
				If c.cType = 1 And c.num = n
					h = 1
					Exit
				End If
			Next
			If h = 0
				num = h
				Exit
			End If
		Next
	EndMethod
	Method Remove() 
		tcpsock.Close() 
		TNet.Clients.Remove(Self) 
		MPrint "lost client"
	End Method
End Type

'#Region INI
' Code for handling INI files, taken from BlitzBasic forums, by Perturbatio
' www.blitzmax.com/codearcs/codearcs.php?code=1890
' Modified by Chris Eykamp to make it more flexible
' Code in this section is public domain

' CE   Apr-2007 Better support for comments and whitespace in INI file
' CE 26-Apr-2007 Fixed problem with empty values (lines that look like key =)

Function SplitString:TList(inString:String, Delim:String) 
	Local tempList:TList = New TList
	Local currentChar:String = ""
	Local count:Int = 0
	Local TokenStart:Int = 0
	
	If Len(Delim) < 1 Then Return Null
	
	inString = Trim(inString) 
	
	For count = 0 Until Len(inString) 
		If inString[count..count + 1]= delim Then
			tempList.AddLast(inString[TokenStart..count]) 
			TokenStart = count + 1
		End If
	Next
	tempList.AddLast(inString[TokenStart..count]) 
	Return tempList
End Function


Type TIniSection
	Field Name:String
	Field Values:TMap
	
	
	Method SetValue(Key:String, Value:Object) 
		Values.Insert(Key, Value) 
	End Method
	
	
	Method GetValue:String(Key:String) 
		Return String(Values.ValueForKey(Key)) 
	End Method
	
	
	Method DeleteValue(Key:String) 
		Values.Remove(Key) 
	End Method
	
	
	Method GetSectionText:String() 
		Local result:String = "[" + Name + "]~r~n"
		
		For Local s:Object = EachIn Values.Keys() 
			result = result + String(s) + "=" + String(Values.ValueForKey(s)) + "~r~n"
		Next
		
		Return result + "~r~n"
	End Method
	
	
	Function Create:TIniSection(Name:String) 
		Local tempSection:TIniSection = New TIniSection
			tempSection.Name = Name
			tempSection.Values = New TMap
		Return tempSection
	End Function
	
End Type



Type TSectionList
	Field _Sections:TIniSection[]
	
	Method GetSection:TIniSection(sectionName:String) 
	
		For Local section:TIniSection = EachIn _Sections
			If section.Name = sectionName Then Return section
		Next
		
		Return Null
		
	End Method
	
	
	Method AddSection:TIniSection(sectionName:String) 
		Local currentLength:Int = Len(_Sections) 
		
			_Sections = _Sections[..currentLength + 1]
			_Sections[currentLength]= TIniSection.Create(sectionName) 
		
		Return _Sections[currentLength]
	End Method
	
	
	Method RemoveSection:Int(sectionName:String) 
		Local currentLength:Int = Len(_Sections) 
		
		For Local i:Int = 0 To currentLength - 1
			If _Sections[i].Name = sectionName Then
				If i < currentLength - 1 Then
					For Local x:Int = i To currentLength - 2
						_Sections[x]= _Sections[x + 1]
					Next
				EndIf
				_Sections = _Sections[..currentLength - 1]
				
				Return True
				
			EndIf
		Next
		
		Return False
	End Method
	
	
	Function Create:TSectionList() 
		Local tempSectionList:TSectionList = New TSectionList
			
		Return tempSectionList
	End Function
	
End Type



Type TPertIni
	Field Filename:String
	Field Loaded:Int
	Field Saved:Int
	Field Sections:TSectionList
	
	
	Method Load:Int() 
		Local file:TStream
		Local line:String
		Local tempList:TList
		Local tempArray:Object[]
		Local currentSection:String = ""
		Local error:String
		Local v:String
		
		
		If FileType(Filename) = 1 Then

			file:TStream = ReadStream(FileName) 
			
			While not Eof(file) 
				
				line = cleanVal(ReadLine(file)) 
				
				
				If not (Line[..1]= ";") Then		' Skip lines that are just comments 
					
					If Line[..1]= "[" and Line[Len(Line) - 1..]= "]" Then
						currentSection = Line[1..Len(Line) - 1]
						
						AddSection(currentSection) 
					Else
						If Len(currentSection) > 0 and Len(line) > 0 Then
							tempArray = SmartSplit(Line, "=") 
							If tempArray <> Null
							
								If tempArray.Length > 1 Then
									v = String(tempArray[1]).Trim() 
								Else
									v = ""
								EndIf
								
								SetSectionValue(currentSection, String(tempArray[0]).Trim(), v) 
							EndIf
						Else If Len(Line) > 0 Then
							Return False 'no section header found' 
						EndIf
					EndIf
				EndIf
			Wend
			
			CloseStream(file) 
		
		EndIf
		
		Return False
	End Method
	
	
	Method Save:Int(Overwrite:Int = False) 
		Local file:TStream
		Local ft:Int = FileType(Filename) 
		
		If ft = 0 or (ft = 1 and Overwrite = True) Then
			file:TStream = WriteStream(FileName) 
			WriteString(file, GetIniText()) 
			CloseStream(file) 
		Else
			Return False
		EndIf
		
	End Method
	
	
	Method AddSection:TIniSection(sectionName:String) 
		Return Sections.AddSection(sectionName) 
	End Method
	
	
	Method GetSection:TIniSection(sectionName:String) 
		Return Sections.GetSection(sectionName) 
	End Method
	
	
	Method SetSectionValue(sectionName:String, Key:String, Value:String) 
		For Local i:Int = 0 To Len(Sections._Sections) - 1
			If Sections._Sections[i].Name = sectionName Then
				Sections._Sections[i].SetValue(Key, Value) 
				Return
			EndIf
		Next
	End Method
	
	
	Method DeleteSectionValue(sectionName:String, Key:String) 
		For Local i:Int = 0 To Len(Sections._Sections) - 1
			If Sections._Sections[i].Name = sectionName Then
				Sections._Sections[i].DeleteValue(Key) 
				Return
			EndIf
		Next
	End Method
	
	
	Method GetSectionValue:String(sectionName:String, Key:String) 
		For Local i:Int = 0 To Len(Sections._Sections) - 1
			If Sections._Sections[i].Name = sectionName Then
				Return Sections._Sections[i].GetValue(Key) 
			EndIf
		Next
	End Method
	
	
	Method GetIniText:String() 
		Local result:String
			For Local section:TIniSection = EachIn Sections._Sections
				 result:+section.GetSectionText() 
			Next
		Return result
	End Method
	
	
	Function Create:TPertIni(filename:String) 
		Local tempIni:TPertIni = New TPertIni
			tempIni.Filename = filename
			tempIni.Sections:TSectionList = TSectionList.Create() 
		Return tempIni
	End Function
End Type





'###############################################################################
' Trim any whitespace or comments from Value

Function cleanVal:String(s:String) 
	
	If s Then Return SmartSplit(s.Trim(), ";")[0]Else Return Null

End Function

'###############################################################################
' Split a String into substrings
' From www.blitzbasic.com/codearcs/codearcs.php?code=1560
' by CoderLaureate, bug fix by Chris Eykamp
' This code has been declared by its author To be Public Domain code.

Function SmartSplit:String[](str:String, dels:String, text_qual:String = "~q") 
	Local Parms:String[]= New String[1]
	Local pPtr:Int = 0
	Local chPtr:Int = 0
	Local delPtr:Int = 0
	Local qt:Int = False
	Local str2:String = ""
	
	Repeat
		Local del:String = Chr(dels[delPtr]) 
		Local ch:String = Chr(str[chPtr]) 
		If ch = text_qual Then
			If qt = False Then
				qt = True
			Else
				qt = False
			End If
		End If
		If ch = del Then
			If qt = True Then str2:+ch
		Else
			str2:+ch
		End If
		If ch = del or chPtr = str.Length - 1 Then
			If qt = False Then
				Parms[pPtr]= str2.Trim() 
				str2 = ""
				pPtr:+1
				Parms = Parms[..pPtr + 1]
				If dels.Length > 1 and delPtr < dels.Length Then delPtr:+1
			End If
		End If
		chPtr:+1
		If chPtr >= str.Length Then Exit
	Forever
	If Parms.Length > 1 Then Parms = Parms[..Parms.Length - 1]
	Return Parms
			
End Function


'#End Region 