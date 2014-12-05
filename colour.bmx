Function ColRGBtoHSL:Byte[] (r:Byte, g:Byte, b:Byte)
	Throw "Todo"
End Function

Function ColHSLtoRGB:Byte[] (hue:Byte, sat:Byte, lum:Byte)
	''Check if colour is grey, return a grey if it is
	If sat = 0
		Return ColCreate(lum,lum,lum)
	EndIf
	''Initialise variables
	Local q:Float = 0, p:Float = 0
	Local color:Byte[3]
	Local t:Float[3]
	''Divide arguments by 255 so that they lie within 0 and 1
	Local h:Float = hue / 255, s:Float = sat / 255, l:Float = lum / 255

	If l < 0.5
		q = l * (s + 1)
	Else
		q = l + s - (l * s)
	EndIf
	t[0] = h + (1 / 3) 'r
	t[1] = h           'g
	t[2] = h - (1 / 3) 'b
	For Local c:Int = 0 To 2
		If t[c] < 0 t[c] = t[c] + 1
		If t[c] > 1 t[c] = t[c] - 1
		
		If t[c] < (1 / 6)
			color[c] = 255 * (p + ((q - p) * 6 * t[c]))
		ElseIf (1 / 6) <= t[c] And t[c] < 0.5
			color[c] = 255 * q
		ElseIf 1 / 2 <= t[c] And t[c] < (2 / 3)
			color[c] = 255 * (p + ((q - p) * 6 * ((2 / 3) - t[c])))
		Else
			color[c] = 255 * p
		EndIf
	Next
	
	Return color
	
End Function

Function ColCreate:Byte[] (r:Byte, g:Byte, b:Byte)
	Local c:Byte[3] 
	c[0] = r
	c[1] = g
	c[2] = b
	Return c
End Function

Function Sendcolor(col:Byte[] ) 
	TNet.MByte(col[0] ) 
	TNet.MByte(col[1] ) 
	TNet.MByte(col[2] ) 
End Function

