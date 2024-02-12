package audio

import c "core:c/libc"
import "core:fmt"
import "core:log"
import "core:math"
import "core:slice"
import "core:testing"

import rl "vendor:raylib"

import "../global"


init :: proc() {
	rl.InitAudioDevice()
	rl.AttachAudioMixedProcessor(processAudio)
	global.sound = rl.LoadSound("assets/audio/Toreadors.mp3")
}

update :: proc() {
	for sample in global.sampleLeft[:global.sampleCount] {
		global.left += sample

	}
	for sample in global.sampleRight[:global.sampleCount] {
		global.right += sample
	}
}

processAudio :: proc "c" (bufferData: rawptr, frames: c.uint) {

	global.samples = (cast([^]f32)bufferData)[:frames * 2]
	global.sampleCount = frames

	for frame in 0 ..< frames {
		global.samples[frame * 2 + 0] *= global.panLeft
		global.samples[frame * 2 + 1] *= global.panRight
		global.sampleLeft[frame] = global.samples[frame * 2 + 0]
		global.sampleRight[frame] = global.samples[frame * 2 + 1]
	}

	global.sampleLeft = global.sampleLeft[:global.sampleCount]
	global.sampleRight = global.sampleRight[:global.sampleCount]
}

fft :: proc(x: ^[]complex32, n: u32) {
	if (n <= 1) {return}
	assert(n & (n - 1) == 0, fmt.tprintf("fft need padding to be power of 2 => %v", n))

	// odd and even
	even: []complex32 = make([]complex32, n / 2)
	defer delete(even)
	odd: []complex32 = make([]complex32, n / 2)
	defer delete(odd)
	for i in 0 ..< (n / 2) {
		even[i] = x[2 * i]
		odd[i] = x[2 * i + 1]
	}

	// recurse 
	fft(&even, n / 2)
	fft(&odd, n / 2)

	// combine
	for k in 0 ..< n / 2 {
		theta := -2.0 * math.PI * f32(k) / f32(n)
		t: complex32
		t = complex(
			(math.cos(theta) * real(odd[k]) + math.sin(theta) * imag(odd[k])),
			(math.cos(theta) * imag(odd[k]) - math.sin(theta) * real(odd[k])),
		)
		x[k] = complex(real(even[k]) + real(t), imag(even[k]) + imag(t))
		x[k + n / 2] = complex(real(even[k]) - real(t), imag(even[k]) - imag(t))
	}
}

@(test)
test_fft :: proc(t: ^testing.T) {
	signal: []complex32 =  {
		complex(-0.9, 0),
		complex(-0.5, 0),
		complex(-0.1, 0),
		complex(0.0, 0),
		complex(0.1, 0),
		complex(0.7, 0),
		complex(0.3, 0),
		complex(-0.4, 0),
	}

	fft(&signal, 8)

	for i in signal {
		fmt.printf("r: %v c: %v\n", real(i), imag(i))
	}
}
