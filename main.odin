package main

import c "core:c/libc"
import "core:fmt"

import rl "vendor:raylib"

panLeft: f32
panRight: f32
sound: rl.Sound
playing := false

sampleCount: u32 = 0

sampleLeft := [1024]f32{}
sampleRight := [1024]f32{}

left: f32 = 0
right: f32 = 0

main :: proc() {
	init()
	for !rl.WindowShouldClose() {
		update()
		draw()
		clean()
	}
}

init :: proc() {
	rl.InitWindow(800, 450, "raylib [core] example - basic window")
	rl.InitAudioDevice()
	rl.AttachAudioMixedProcessor(processAudio)
	sound = rl.LoadSound("assets/audio/B.mp3")
	rl.SetTargetFPS(60)
	rl.HideCursor()
}

clean :: proc() {
	left = 0
	right = 0
}

update :: proc() {
	if (rl.IsKeyPressed(rl.KeyboardKey.SPACE)) {
		rl.PlaySound(sound)
		playing = true
	}

	for sample in sampleLeft[:sampleCount] {
		left += sample

	}
	for sample in sampleRight[:sampleCount] {
		right += sample
	}
	fmt.print("sample", sampleCount, "Left: ", left, " Right: ", right, "\n")

}
draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	rl.DrawText(
		"Press space to play the music",
		rl.GetScreenWidth() / 2 - 170,
		rl.GetScreenHeight() / 2 - 20,
		20,
		rl.LIGHTGRAY,
	)
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

	height: f32 = cast(f32)rl.GetScreenHeight()
	width: f32 = cast(f32)rl.GetScreenWidth()

	for i in 0 ..< sampleCount {
		/*
		rl.DrawPixel(
			cast(i32)(sampleRight[i] * width * 2 + width / 2),
			cast(i32)(sampleLeft[i] * height * 2 + height / 2),
			rl.Color {
				cast(u8)(255 * panLeft),
				cast(u8)(255 * panRight),
				cast(u8)(255 * panRight),
				255,
			},
		)
		*/
		rl.DrawLine(
			cast(i32)(sampleRight[i] * width * 2 + width / 2),
			cast(i32)(sampleLeft[i] * height * 2 + height / 2),
			cast(i32)(sampleRight[i + 1] * width * 2 + width / 2),
			cast(i32)(sampleLeft[i + 1] * height * 2 + height / 2),
			rl.Color {
				cast(u8)(255 * panLeft),
				cast(u8)(255 * panRight),
				cast(u8)(255 * panRight),
				255,
			},
		)

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
