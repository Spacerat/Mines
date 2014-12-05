rem
Incbin "res/back1.jpg"
Incbin "res/back2.jpg"
Incbin "res/back3.jpg"
Incbin "res/frame.png"
Incbin "res/backblue.jpg"
Incbin "res/block.png"
Incbin "res/blockrevealed.png"
Incbin "res/flag.png"
Incbin "res/bomb.png"
Incbin "res/expl.wav"
IncBin "res/textbox.png"
IncBin "res/arialbd.ttf"
incbin "res/clock.png"
endrem

Global IBack1:TSImage = LoadSImage("res/back1.jpg")
Global IBack2:TSImage = LoadSImage("res/back2.jpg")
Global IBack3:TSImage = LoadSImage("res/back3.jpg")
Global IFrame:TSImage = LoadSImage("res/frame.png")

IFrame.img.handle_x = 26
IFrame.img.handle_y = 26
Global framex:Float = 26, framey:Float = 26
Global IBackImg:TSImage = loadSImage("res/back.jpg")
Global IBlock:TSImage = loadSImage("res/block.png")
Global IBlockRev:TSImage = loadSImage("res/blockrevealed.png")
Global IFlag:TSImage = loadSImage("res/flag.png")
'Global IBomb:TSImage = loadSImage("res/clock.png")
Global IMine:TSImage = loadSImage("res/bomb.png")
Global IMineImg:TImage = LoadImage("res/bomb.png")
Global IClock:TSImage = loadSImage("res/clock.png")
Global ITextBox:TSImage = loadSImage("res/textbox.png")
Global SExplosion:TSound = LoadSound("res/expl.wav")

Global FArialBold40:TImageFont = LoadImageFont("res/arialbd.ttf", 40)
Global FArialBold20:TImageFont = LoadImageFont("res/arialbd.ttf", 20)
