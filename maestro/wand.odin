package maestro
import "../global"
import rl "vendor:raylib"

draw :: proc() {
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
