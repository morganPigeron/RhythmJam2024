package audio

import c "core:c/libc"
import "core:fmt"
import "core:log"
import "core:math"
import "core:slice"
import "core:testing"
import "core:time"

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

	//low pass 
	dt: f32 = 0.16
	rc: f32 = 0.01
	alpha: f32 = dt / (rc + dt)
	/*
	global.samples[0] *= alpha
	for i in 1 ..< frames * 2 {
		global.samples[i] = alpha * global.samples[i - 1] + (1 - alpha) * global.samples[i]
	}
	*/
	//low pass end 

	//high pass
	/*
	dth: f32 = 0.16
	rch: f32 = 0.01
	alphaH := rch / (rch + dth)
	for i in 1 ..< frames {
		left := i * 2 + 0
		right := i * 2 + 1
		global.samples[left] =
			alphaH * global.samples[left - 1] +
			alpha * (global.samples[left] - global.samples[left - 1])

		global.samples[right] =
			alphaH * global.samples[right - 1] +
			alpha * (global.samples[right] - global.samples[right - 1])
	}
	*/
	//high pass filter 


	for frame in 0 ..< frames {
		left := frame * 2 + 0
		right := frame * 2 + 1
		global.samples[left] *= global.panLeft * global.panVertical
		global.samples[right] *= global.panRight * global.panVertical

		global.sampleLeft[frame] = global.samples[left]
		global.sampleRight[frame] = global.samples[right]
	}
}


fft_sequential :: proc(x: ^[]complex32, n: u32) {
	bit_invert(x, n)
	calc_sub_fft(x, n)

	for i in 0 ..< n {
		x[i] = complex(real(x[i]) / f16(n) * 2.0, imag(x[i]) / f16(n) * 2.0)
	}
	x[0] = complex(real(x[0]) / 2.0, imag(x[0]) / 2.0)

}

bit_invert :: proc(x: ^[]complex32, n: u32) {
	mv := n / 2
	for i in 1 ..< n {
		k := i
		mv := n / 2
		rev: u32 = 0
		for k > 0 { 	// invert index 
			if k % 2 > 0 {
				rev += mv
			}
			k /= 2
			mv /= 2
		}
		{ 	// switch the actual sample and the bitinverted one
			if i < rev {
				y := x[rev]
				x[rev] = x[i]
				x[i] = y
			}
		}
	}
}

calc_sub_fft :: proc(x: ^[]complex32, n: u32) {
	k: u32 = 1
	for k <= u32(n / 2) {
		m := 0
		for u32(m) <= u32(n) - 2 * k {
			for i in m ..< m + int(k) {
				w: complex32 = complex(
					math.cos(math.PI * f32((i - m)) / f32(k)),
					math.sin(math.PI * f32((i - m)) / f32(k)),
				)
				h := x[i + int(k)] * w
				v := x[i]
				x[i] += h
				x[i + int(k)] = v - h
			}
			m += 2 * int(k)
		}
		k *= 2
	}
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

@(test)
test_fft_sequential :: proc(t: ^testing.T) {
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

	fft_sequential(&signal, 8)

	for i in signal {
		fmt.printf("r: %v c: %v\n", real(i), imag(i))
	}
}
//https://www.codeproject.com/Articles/619688/Quick-FFT
