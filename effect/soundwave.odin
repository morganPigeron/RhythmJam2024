package effect

import "core:log"
import "core:math"

import rl "vendor:raylib"

import "../audio"
import "../global"

WaveEffect :: proc() {
	width := cast(f32)(rl.GetScreenWidth())
	height := cast(f32)(rl.GetScreenHeight())

	rectWidth: i32 = cast(i32)math.ceil(width / (f32(global.sampleCount) / 2))

	for i in 0 ..< global.sampleCount {
		rl.DrawRectangle(
			i32(i) * i32(rectWidth),
			i32(height) / 2,
			i32(rectWidth),
			i32(global.sampleLeft[i] * 2000),
			rl.Color {
				cast(u8)(255 * global.panLeft),
				cast(u8)(255 * global.panRight),
				cast(u8)(255 * global.panRight),
				255,
			},
		)
		rl.DrawRectangle(
			i32(i) * rectWidth,
			i32(height) / 2 - i32(global.sampleRight[i] * 2000),
			rectWidth,
			i32(global.sampleRight[i] * 2000),
			rl.Color{255, 127, 100, 255},
		)

		rl.DrawCircleSector(
			rl.Vector2{f32(i32(i) * rectWidth), height / 4},
			(global.sampleRight[i] * 200),
			0,
			180,
			10,
			rl.Color{255, 0, 0, 255},
		)
	}
}

WaveSpectrumEffect :: proc() {
	width := cast(f32)(rl.GetScreenWidth())
	height := cast(f32)(rl.GetScreenHeight())


	rectWidth: i32 = cast(i32)math.ceil(width / (f32(global.sampleCount)))

	paddedCount := global.sampleCount
	if paddedCount % 2 != 0 {
		paddedCount += 1
	}

	samplesToProcessLeft := make([]complex32, paddedCount) // all init to 0 so padded are good
	defer delete(samplesToProcessLeft)

	samplesToProcessRight := make([]complex32, paddedCount) // all init to 0 so padded are good
	defer delete(samplesToProcessLeft)

	for i in 0 ..< global.sampleCount {
		samplesToProcessLeft[i] = complex(global.sampleLeft[i], 0)
		samplesToProcessRight[i] = complex(global.sampleRight[i], 0)
	}

	audio.fft(samplesToProcessLeft)
	audio.fft(samplesToProcessRight)

	for i in 0 ..< global.sampleCount {
		rl.DrawRectangle(
			i32(i) * i32(rectWidth),
			i32(height) / 2,
			i32(rectWidth),
			i32(real(samplesToProcessLeft[i]) * 20),
			rl.Color {
				cast(u8)(255 * global.panLeft),
				cast(u8)(255 * global.panRight),
				cast(u8)(255 * global.panRight),
				255,
			},
		)
		rl.DrawRectangle(
			i32(i) * rectWidth,
			i32(height) / 2 - i32(imag(samplesToProcessRight[i]) * 20),
			rectWidth,
			i32(imag(samplesToProcessRight[i]) * 20),
			rl.Color{255, 127, 100, 255},
		)
	}
}
