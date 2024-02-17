package graphics

import "../global"
import rl "vendor:raylib"

init :: proc() {
	global.image = rl.LoadImage("assets/images/bg.png")
	//efer rl.UnloadImage(global.image)
	rl.ImageResize(&global.image, rl.GetScreenWidth(), rl.GetScreenHeight())
	global.texture = rl.LoadTextureFromImage(global.image)

	// HOG
	global.image = rl.LoadImage("assets/images/hog.png")  
	global.sprite = rl.LoadTextureFromImage(global.image) 
	global.frame = 0.0
    global.frameSpeed = 0.1

}
