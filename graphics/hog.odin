package graphics

import "../global"
import rl "vendor:raylib"

init :: proc() {
    
	global.sprite = rl.LoadTextureFromImage("assets/images/hog.png")
	global.frame = 0
    global.frameSpeed = 0.1
}
