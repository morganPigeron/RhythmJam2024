package main

import c "core:c/libc"
import "core:fmt"
import "core:math"
import "core:os"
import "core:time"

import rl "vendor:raylib"

panLeft: f32
panRight: f32
sound: rl.Sound
playing := false

sampleCount: u32 = 0

sampleLeft := [16000]f32{} //OPTIM set this as needed
sampleRight := [16000]f32{} //OPTIM set this as needed

left: f32 = 0
right: f32 = 0

display: c.int

image: rl.Image
texture: rl.Texture
starTexture: rl.Texture

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
	display = rl.GetCurrentMonitor()
	rl.SetWindowSize(rl.GetMonitorWidth(display), rl.GetMonitorHeight(display))
	rl.ToggleFullscreen()
	rl.InitAudioDevice()
	rl.AttachAudioMixedProcessor(processAudio)
	sound = rl.LoadSound("assets/audio/Toreadors.mp3")
	rl.SetTargetFPS(60)
	rl.HideCursor()

	//image
	image = rl.LoadImage("assets/images/bg.png")
	rl.ImageResize(&image, rl.GetScreenWidth(), rl.GetScreenHeight())
	texture = rl.LoadTextureFromImage(image)
	rl.UnloadImage(image)

	//particles
	for i in 0 ..< 200 {
		particles[i].position = rl.Vector2{}
		particles[i].color = rl.Color {
			cast(u8)(255 * panLeft),
			cast(u8)(255 * panRight),
			cast(u8)(255 * panRight),
			cast(u8)(255 * (max(panLeft, panRight) - 0.5)),
		}
		particles[i].size = 10.0
		particles[i].active = false
		particles[i].alpha = 1.0
	}
	starTexture = rl.LoadTexture("assets/images/star.png")

	time.sleep(2 * time.Second)
}

clean :: proc() {
	left = 0
	right = 0
}

input :: proc() {
	if (rl.IsKeyPressed(rl.KeyboardKey.SPACE)) {
		rl.PlaySound(sound)
		playing = true
	}
}

update :: proc() {
	for sample in sampleLeft[:sampleCount] {
		left += sample

	}
	for sample in sampleRight[:sampleCount] {
		right += sample
	}
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTexture(texture, 0, 0, rl.WHITE)

	if !playing {
		rl.DrawText(
			"Press space to play the music",
			rl.GetScreenWidth() / 2 - 170,
			rl.GetScreenHeight() / 2 - 20,
			20,
			rl.LIGHTGRAY,
		)
	}

	if playing {
		rl.DrawCircleV(
			rl.GetMousePosition(),
			20,
			rl.Color {
				cast(u8)(255 * panLeft),
				cast(u8)(255 * panRight),
				cast(u8)(255 * panRight),
				cast(u8)(255 * (max(panLeft, panRight) - 0.5)),
			},
		)
	}

	width := cast(f32)(rl.GetScreenWidth())
	height := cast(f32)(rl.GetScreenHeight())

	rectWidth: i32 = cast(i32)math.ceil(width / (f32(sampleCount) / 2))

	for i in 0 ..< sampleCount {
		rl.DrawRectangle(
			i32(i) * i32(rectWidth),
			i32(height) / 2,
			i32(rectWidth),
			i32(sampleLeft[i] * 2000),
			rl.Color {
				cast(u8)(255 * panLeft),
				cast(u8)(255 * panRight),
				cast(u8)(255 * panRight),
				255,
			},
		)
		rl.DrawRectangle(
			i32(i) * rectWidth,
			i32(height) / 2 - i32(sampleRight[i] * 2000),
			rectWidth,
			i32(sampleRight[i] * 2000),
			rl.Color{255, 127, 100, 255},
		)

		rl.DrawCircleSector(
			rl.Vector2{f32(i32(i) * rectWidth), height / 4},
			(sampleRight[i] * 200),
			0,
			180,
			10,
			rl.Color{255, 0, 0, 255},
		)
		//calculate fft on sampleLeft and sampleRight
	}

	rl.EndDrawing()
}

processAudio :: proc "c" (bufferData: rawptr, frames: c.uint) {
	samples := transmute([^]f32)bufferData //get our type
	sampleCount = frames * 2

	mouse := rl.GetMousePosition()
	screenWidth := cast(f32)rl.GetScreenWidth()
	// normalize from 1 to 0 and 0 to 1
	panLeft = 1 - (mouse.x / screenWidth)
	panRight = mouse.x / screenWidth

	for frame in 0 ..= frames {
		samples[frame * 2 + 0] *= panLeft
		samples[frame * 2 + 1] *= panRight

		sampleLeft[frame] = samples[frame * 2 + 0]
		sampleRight[frame] = samples[frame * 2 + 1]
	}
}
