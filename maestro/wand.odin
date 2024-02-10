package maestro
import "../global"
import rl "vendor:raylib"

draw :: proc() {
	mouse := rl.GetMousePosition()

	//mouse
	rl.DrawCircleV(
		mouse,
		20,
		rl.Color {
			cast(u8)(255 * global.panLeft),
			cast(u8)(255 * global.panRight),
			cast(u8)(255 * global.panRight),
			cast(u8)(200),
		},
	)
	//outline
	rl.DrawCircleLinesV(mouse, 20, rl.Color{0, 0, 0, 200})

	//path
	p1 := rl.Vector2{20, 20}
	c2 := rl.Vector2{200, 20}
	c3 := rl.Vector2{50, 150}
	p4 := rl.Vector2{200, 200}
	path := [?]rl.Vector2{p1, c2, c3, p4}
	for point in path {
		rl.DrawCircleV(point, 20, rl.PINK)
	}
	rl.DrawSplineBezierCubic(&path[0], 4, 5, rl.PINK)

	//rl.CheckCollisionPointPoly()
}
