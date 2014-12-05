Incbin "res/back1.png"
Incbin "res/back2.png"
Incbin "res/back3.png"
Incbin "res/frame.png"
Incbin "res/backblue.jpg"
Incbin "res/block.png"
Incbin "res/flag.png"
Incbin "res/bomb.png"
Incbin "res/expl.wav"

Global IBack1:TSImage = LoadSImage("incbin::res/back1.png", GAMESIZEW / 350, GAMESIZEH / 450) 
Global IBack2:TSImage = LoadSImage("incbin::res/back2.png", GAMESIZEW / 350, GAMESIZEH / 450) 
Global IBack3:TSImage = LoadSImage("incbin::res/back3.png", GAMESIZEW / 350, GAMESIZEH / 450) 
Global IFrame:TSImage = LoadSImage("incbin::res/frame.png", GAMESIZEW / 700, GAMESIZEW / 700) 
IFrame.img.handle_x = 26
IFrame.img.handle_y = 26
Global framex:Float = 26, framey:Float = 26
Global IBackImg:TSImage = loadSImage("incbin::res/backblue.jpg", GAMESIZEW / 700, GAMESIZEH / 900) 
Global IBlock:TSImage = loadSImage("incbin::res/block.png", GAMESIZEW / 692, GAMESIZEW / 692) 
Global IFlag:TSImage = loadSImage("incbin::res/flag.png", GAMESIZEW / 700, GAMESIZEW / 700) 
Global IBomb:TSImage = loadSImage("incbin::res/bomb.png", GAMESIZEW / 700, GAMESIZEW / 700) 
Global SExplosion:TSound = LoadSound("incbin::res/expl.wav") 