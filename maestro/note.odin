package maestro

import "core:encoding/csv"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:testing"

note :: struct {
	time:     uint,
	x:        uint,
	y:        uint,
	duration: uint,
	size:     uint,
	score:    uint,
}

//FIXME return them in chronological order
from_string :: proc(text: [][]string) -> []note {
	notes := make([]note, len(text))
	for line, i in text {
		note := note{}
		note.time, _ = strconv.parse_uint(line[0])
		note.x, _ = strconv.parse_uint(line[1])
		note.y, _ = strconv.parse_uint(line[2])
		note.duration, _ = strconv.parse_uint(line[3])
		note.size, _ = strconv.parse_uint(line[4])
		note.score, _ = strconv.parse_uint(line[5])
		notes[i] = note
	}
	return notes
}
@(test)
test_from_string :: proc(t: ^testing.T) {
	expected: []note = {note{15, 16, 17, 50, 20, 100}}
	text := to_string(expected)
	defer delete(text)
	result := from_string(text)
	defer delete(result)
	testing.expect_value(t, result[0], expected[0])
}

to_string :: proc(notes: []note) -> [][]string {
	text := make([][]string, len(notes))
	for note, i in notes {
		text[i] = make([]string, 6)
		text[i][0] = fmt.aprintf("%v", note.time)
		text[i][1] = fmt.aprintf("%v", note.x)
		text[i][2] = fmt.aprintf("%v", note.y)
		text[i][3] = fmt.aprintf("%v", note.duration)
		text[i][4] = fmt.aprintf("%v", note.size)
		text[i][5] = fmt.aprintf("%v", note.score)
	}
	return text
}
@(test)
test_to_string :: proc(t: ^testing.T) {
	note: []note = {note{15, 16, 17, 50, 20, 100}}
	text := to_string(note)
	defer delete(text)
	expectedText: [][]string = {{"15", "16", "17", "50", "20", "100"}}

	for line, i in text {
		for value, j in line {
			testing.expect_value(t, value, expectedText[i][j])
		}
	}
}

from_file :: proc(path: string) -> []note {
	data, success := os.read_entire_file_from_filename(path)
	if !success {
		log.errorf("Cannot read file %v", path)
		return []note{}
	}

	text := fmt.aprintf("%s", data)
	result, err := csv.read_all_from_string(text)
	if err != nil {
		log.errorf("Cannot parse file %v", path)
		os.exit(-1)
	}
	return from_string(result)
}

to_file :: proc(path: string, notes: []note) {
	file, err := os.open(path, os.O_WRONLY | os.O_CREATE)
	if err != os.ERROR_NONE {
		log.errorf("Cannot open file %v , error : %v", path, err)
		os.exit(-1)
	}
	defer os.close(file)

	text := to_string(notes)
	defer delete(text)
	writer := csv.Writer{}
	csv.writer_init(&writer, os.stream_from_handle(file))
	csv.write_all(&writer, text)
}
@(test)
test_to_file :: proc(t: ^testing.T) {
	path := "./test.csv"
	notes: []note = {note{15, 16, 17, 50, 20, 100}}
	to_file(path, notes)
	result := from_file(path)
	testing.expect_value(t, notes[0], result[0])
}
