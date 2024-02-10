package effect

import "core:math"
import rl "vendor:raylib"

WaveEffect :: proc(
	sampleCount: u32,
	sampleLeft: []f32,
	sampleRight: []f32,
	panLeft: f32,
	panRight: f32,
) {
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
	}
}
