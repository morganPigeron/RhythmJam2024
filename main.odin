package main

import c "core:c/libc"
import "core:fmt"
import "core:log"
import "core:math"
import "core:mem"
import "core:os"
import "core:time"

import "audio"
import "effect"
import "global"
import "graphics"
import "maestro"

import rl "vendor:raylib"



main :: proc() {
	context.logger = log.create_console_logger()
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, context.allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)

	reset_tracking_allocator :: proc(a: ^mem.Tracking_Allocator) -> bool {
		leaks := false
		for key, value in a.allocation_map {
			fmt.printf("%v: leaked %v bytes\n", value.location, value.size)
			leaks = true
		}
		mem.tracking_allocator_clear(a)
		return leaks
	}

	init()
	for !rl.WindowShouldClose() {
		input()
		update()
		draw()
	}

	clean()
	reset_tracking_allocator(&tracking_allocator)
}

init :: proc() {
	// set full screen
	rl.InitWindow(1920, 1080, "divergent orchestra")
	global.display = rl.GetCurrentMonitor()
	rl.SetWindowSize(rl.GetMonitorWidth(global.display), rl.GetMonitorHeight(global.display))
	rl.ToggleFullscreen()
	rl.SetTargetFPS(60)
	rl.HideCursor()

	audio.init()
	graphics.init()
	maestro.init()

	for i in 0..<40 {  
		global.spritePositions[i] = rl.Vector2{  
			cast(f32)rl.GetRandomValue(500, 1300),  
			cast(f32)rl.GetRandomValue(870, 850),  
		}  
	}  

	// be sure all is loaded before continuing
	waitForGameLoad()
	log.debug("Init done")
}

input :: proc() {

	mouse := rl.GetMousePosition()
	screenWidth := cast(f32)rl.GetScreenWidth()
	screenHeight := cast(f32)rl.GetScreenHeight()
	// normalize from 1 to 0 and 0 to 1
	global.panLeft = 1 - (mouse.x / screenWidth)
	global.panRight = mouse.x / screenWidth
	global.panVertical = 1 - (mouse.y / screenHeight) / 3
	
	if (rl.IsKeyPressed(rl.KeyboardKey.SPACE)) {
		rl.PlaySound(global.sound)
		global.playing = true
	}

	if (rl.IsKeyPressed(rl.KeyboardKey.E)) {
		global.editor = !global.editor
	}

	maestro.input()
}

update :: proc() {
	audio.update()
	if global.playing {
		global.musicTime += 1
	}
	global.frameTimer += global.frameSpeed  
	if global.frameTimer >= 1.0 {  
    global.frameTimer -= 1.0  
    global.frame += 1  
    if global.frame >= global.spriteFrameCount {  
        global.frame = 0  
    }  
}

}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	rl.DrawTexture(global.texture, 0, 0, rl.WHITE)
	// HOG 
	
	
	frameWidth := global.sprite.width / cast(i32)global.spriteFrameCount
    frameRec := rl.Rectangle{cast(f32)global.frame * cast(f32)frameWidth, 0, cast(f32)frameWidth, cast(f32)global.sprite.height}  
    rl.DrawTextureRec(global.sprite, frameRec, rl.Vector2{870, 850}, rl.WHITE) 

	// Group of hog :
	for i in 0..<40 {  
		rl.DrawTextureRec(global.sprite, frameRec, global.spritePositions[i], rl.WHITE)   
	}  

	if !global.playing {

		rl.DrawText(
			"Work in progress !",
			rl.GetScreenWidth() / 2 - 100,
			20,
			20,
			rl.LIGHTGRAY,
		)
		rl.DrawText(
			"Press E to enable editor mode, and start placing notes !",
			rl.GetScreenWidth() / 2 - 100,
			40,
			20,
			rl.LIGHTGRAY,
		)
		rl.DrawText(
			"When in editor mode press S to save your notes",
			rl.GetScreenWidth() / 2 - 100,
			60,
			20,
			rl.LIGHTGRAY,
		)
		rl.DrawText(
			"Press ESC to quit the game",
			rl.GetScreenWidth() / 2 - 100,
			80,
			20,
			rl.LIGHTGRAY,
		)
		rl.DrawText(
			"Press space to play the music",
			rl.GetScreenWidth() / 2 - 170,
			rl.GetScreenHeight() / 2 - 20,
			20,
			rl.LIGHTGRAY,
		)
	}

	if global.playing {
		maestro.draw()
		//effect.WaveEffect()

	}

	debug()
	rl.EndDrawing()
}

clean :: proc() {
	maestro.clean()
	rl.UnloadTexture(global.sprite)
}

waitForGameLoad :: proc() {
	ready := false
	for !ready {
		if rl.IsAudioDeviceReady() &&
		   rl.IsSoundReady(global.sound) &&
		   rl.IsImageReady(global.image) &&
		   rl.IsWindowReady() &&
		   rl.IsTextureReady(global.texture) {
			ready = true
		}
	}

	time.sleep(1000)
}

debug :: proc() {
	rl.DrawText(fmt.ctprintf("FPS: %v", rl.GetFPS()), 20, 20, 20, rl.LIGHTGRAY)
	rl.DrawText(fmt.ctprintf("Music time: %v", global.musicTime), 20, 40, 20, rl.LIGHTGRAY)
	rl.DrawText(fmt.ctprintf("Editor mode: %t", global.editor), 20, 60, 20, rl.LIGHTGRAY)
	rl.DrawText(fmt.ctprintf("Score: %v", global.score), 20, 80, 20, rl.LIGHTGRAY)
	effect.WaveSpectrumEffect(20, 150, 150, 100)
}
