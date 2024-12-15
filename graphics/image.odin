package graphics

import "../encoded"
import "../global"
import rl "vendor:raylib"

init :: proc() {
	global.image = rl.LoadImageFromMemory(".png", &encoded.bg, len(encoded.bg))
	//efer rl.UnloadImage(global.image)
	rl.ImageResize(&global.image, rl.GetScreenWidth(), rl.GetScreenHeight())
	global.texture = rl.LoadTextureFromImage(global.image)

	// HOG
	global.image = rl.LoadImageFromMemory(".png", &encoded.hog, len(encoded.hog))
	global.sprite = rl.LoadTextureFromImage(global.image)
	global.frame = 0.0
	global.frameSpeed = 0.1

}
