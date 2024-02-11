package maestro
import "../global"
import rl "vendor:raylib"


notes := [dynamic]note{}

indexedNotes :: struct {
	index: int,
	note:  note,
}

displayedCircle := [5000]indexedNotes{}

init :: proc() {
	notesInFile := from_file("music.csv")
	append(&notes, ..notesInFile)
}

input :: proc() {
	mouse := rl.GetMousePosition()
	if global.editor {

		if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
			append(
				&notes,
				note {
					duration = 150,
					score = 100,
					size = 20,
					time = uint(global.musicTime),
					x = uint(mouse.x),
					y = uint(mouse.y),
				},
			)
		}

		if rl.IsKeyPressed(rl.KeyboardKey.S) {
			to_file("music.csv", notes[:])
		}
	}
}

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


	//FIXME this can be optimized if we remove old notes and only check next one
	displayed := 0
	for note, i in notes {
		if uint(global.musicTime) == note.time ||
		   uint(global.musicTime) < (note.time + note.duration) &&
			   uint(global.musicTime) > note.time {
			rl.DrawCircle(i32(note.x), i32(note.y), f32(note.size), rl.RED)
			displayedCircle[displayed] = indexedNotes{i, note}
			displayed += 1
		}
	}


	//collision detection
	if !global.editor && rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
		for indexedNote in displayedCircle[:displayed] {
			note := indexedNote.note
			if rl.CheckCollisionPointCircle(
				   mouse,
				   rl.Vector2{f32(note.x), f32(note.y)},
				   f32(note.size),
			   ) {
				rl.DrawCircle(i32(note.x), i32(note.y), f32(note.size), rl.BLUE)
				global.score += int(note.score)
				//remove from global array
				ordered_remove(&notes, indexedNote.index)
			}
		}

	}
}
