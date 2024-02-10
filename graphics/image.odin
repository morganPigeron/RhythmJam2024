package graphics

import "../global"
import rl "vendor:raylib"

init :: proc() {
	global.image = rl.LoadImage("assets/images/bg.png")
	defer rl.UnloadImage(global.image)
	rl.ImageResize(&global.image, rl.GetScreenWidth(), rl.GetScreenHeight())
	global.texture = rl.LoadTextureFromImage(global.image)
}
