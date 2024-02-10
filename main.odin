package main

import c "core:c/libc"
import "core:fmt"
import "core:math"
import "core:os"
import "core:time"

import "audio"
import "effect"
import "global"

import rl "vendor:raylib"


Particle :: struct {
	position: rl.Vector2,
	color:    rl.Color,
	size:     f32,
	active:   bool,
	alpha:    f32,
}

particles := [200]Particle{}

main :: proc() {
	init()
	for !rl.WindowShouldClose() {
		input()
		update()
		draw()
		clean()
	}
}

init :: proc() {
	rl.InitWindow(1920, 1080, "divergent orchestra")
	global.display = rl.GetCurrentMonitor()
	rl.SetWindowSize(rl.GetMonitorWidth(global.display), rl.GetMonitorHeight(global.display))
	rl.ToggleFullscreen()
	audio.init()
	rl.SetTargetFPS(60)
	rl.HideCursor()

	//image
	global.image = rl.LoadImage("assets/images/bg.png")
	rl.ImageResize(&global.image, rl.GetScreenWidth(), rl.GetScreenHeight())
	global.texture = rl.LoadTextureFromImage(global.image)
	rl.UnloadImage(global.image)

	//particles
	for i in 0 ..< 200 {
		particles[i].position = rl.Vector2{}
		particles[i].color = rl.Color {
			cast(u8)(255 * global.panLeft),
			cast(u8)(255 * global.panRight),
			cast(u8)(255 * global.panRight),
			cast(u8)(255 * (max(global.panLeft, global.panRight) - 0.5)),
		}
		particles[i].size = 10.0
		particles[i].active = false
		particles[i].alpha = 1.0
	}
	global.starTexture = rl.LoadTexture("assets/images/star.png")

	time.sleep(2 * time.Second)
}

clean :: proc() {
	global.left = 0
	global.right = 0
}

input :: proc() {
	if (rl.IsKeyPressed(rl.KeyboardKey.SPACE)) {
		rl.PlaySound(global.sound)
		global.playing = true
	}
}

update :: proc() {
	for sample in global.sampleLeft[:global.sampleCount] {
		global.left += sample

	}
	for sample in global.sampleRight[:global.sampleCount] {
		global.right += sample
	}
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTexture(global.texture, 0, 0, rl.WHITE)

	if !global.playing {
		rl.DrawText(
			"Press space to play the music",
			rl.GetScreenWidth() / 2 - 170,
			rl.GetScreenHeight() / 2 - 20,
			20,
			rl.LIGHTGRAY,
		)
	}

	if global.playing {
		rl.DrawCircleV(
			rl.GetMousePosition(),
			20,
			rl.Color {
				cast(u8)(255 * global.panLeft),
				cast(u8)(255 * global.panRight),
				cast(u8)(255 * global.panRight),
				cast(u8)(255 * (max(global.panLeft, global.panRight) - 0.5)),
			},
		)
	}

	effect.WaveEffect(
		global.sampleCount,
		global.sampleLeft[:global.sampleCount],
		global.sampleRight[:global.sampleCount],
		global.panLeft,
		global.panRight,
	)

	rl.EndDrawing()
}
