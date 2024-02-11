package global

import c "core:c/libc"
import rl "vendor:raylib"

//FIXME need to reduce this to the minimum needed
// Contain all global variables

musicTime: u32 = 0
editor := false
score := 0

panLeft: f32
panRight: f32
sound: rl.Sound
playing := false

sampleCount: u32 = 0

samples: [^]f32
sampleLeft: []f32 = make([]f32, 16000) //FIXME set this as needed and delete it
sampleRight: []f32 = make([]f32, 16000) //FIXME set this as needed and delete it

left: f32 = 0
right: f32 = 0

display: c.int

image: rl.Image
texture: rl.Texture
starTexture: rl.Texture
