package audio

import c "core:c/libc"

import rl "vendor:raylib"

import "../global"


init :: proc () {
    rl.InitAudioDevice()
    rl.AttachAudioMixedProcessor(processAudio)
    global.sound = rl.LoadSound("assets/audio/Toreadors.mp3")
}

processAudio :: proc "c" (bufferData: rawptr, frames: c.uint) {

	samples := transmute([^]f32)bufferData //get our type
	global.sampleCount = frames * 2

	mouse := rl.GetMousePosition()
	screenWidth := cast(f32)rl.GetScreenWidth()
	// normalize from 1 to 0 and 0 to 1
	global.panLeft = 1 - (mouse.x / screenWidth)
	global.panRight = mouse.x / screenWidth

	for frame in 0 ..= frames {
		samples[frame * 2 + 0] *= global.panLeft
		samples[frame * 2 + 1] *= global.panRight

		global.sampleLeft[frame] = samples[frame * 2 + 0]
		global.sampleRight[frame] = samples[frame * 2 + 1]
	}
}
