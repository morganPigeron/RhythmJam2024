package effect

import "core:log"
import "core:math"
import "core:time"

import rl "vendor:raylib"

import "../audio"
import "../global"


WaveEffect :: proc() {
	width := cast(f32)(rl.GetScreenWidth())
	height := cast(f32)(rl.GetScreenHeight())

	rectWidth: i32 = cast(i32)math.ceil(width / (f32(global.sampleCount)))

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

isPowerOfTwo :: #force_inline proc(x: u32) -> bool {
	return x & (x - 1) == 0
}

WaveSpectrumEffect :: proc(x: int, y: int, width: int, height: int) {

	paddedCount := global.sampleCount
	if !isPowerOfTwo(paddedCount) { 	// must be power of two for the fft
		n: u32 = 1
		for n < paddedCount {
			n <<= 1
		}
		paddedCount = n
	}

	samplesToProcessLeft := make([]complex32, 2048) //FIXME this need to be optimized , 51x or 1024 can be enough
	samplesToProcessRight := make([]complex32, 2048)
	defer delete(samplesToProcessLeft)
	defer delete(samplesToProcessRight)

	for i in 0 ..< len(global.sampleLeft) { 	// watch out max index
		samplesToProcessLeft[i] = complex(global.sampleLeft[i], 0)
		samplesToProcessRight[i] = complex(global.sampleRight[i], 0)
	}

	audio.fft_sequential(&samplesToProcessLeft, paddedCount)
	audio.fft_sequential(&samplesToProcessRight, paddedCount)

	spectrumLength := 48
	rectWidth: i32 = i32(math.ceil(f32(width) / f32(spectrumLength)))
	for i in 0 ..< spectrumLength {

		ampLeft := math.sqrt(
			real(samplesToProcessLeft[i]) * real(samplesToProcessLeft[i]) +
			imag(samplesToProcessLeft[i]) * imag(samplesToProcessLeft[i]),
		)

		ampRight := math.sqrt(
			real(samplesToProcessRight[i]) * real(samplesToProcessRight[i]) +
			imag(samplesToProcessRight[i]) * imag(samplesToProcessRight[i]),
		)

        ampli :f16= 5000.0

		rl.DrawRectangle(
			i32(x) + i32(i) * i32(rectWidth),
			i32(y) + i32(height) / 2,
			i32(rectWidth),
			i32(ampLeft * ampli),
			rl.Color {
				cast(u8)(255 * global.panLeft),
				cast(u8)(255 * global.panRight),
				cast(u8)(255 * global.panRight),
				255,
			},
		)
		rl.DrawRectangle(
			i32(x) + i32(i) * rectWidth,
			i32(y) + i32(height) / 2 - i32(ampRight * ampli),
			rectWidth,
			i32(ampRight * ampli),
			rl.Color{255, 127, 100, 255},
		)
	}
}
