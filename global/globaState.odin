package global

import c "core:c/libc"
import rl "vendor:raylib"

//OPTIM need to reduce this to the minimum needed
// Contain all global variables

musicTime: u32 = 0
editor := true

panLeft: f32
panRight: f32
sound: rl.Sound
playing := false

sampleCount: u32 = 0

sampleLeft := [16000]f32{} //OPTIM set this as needed
sampleRight := [16000]f32{} //OPTIM set this as needed

left: f32 = 0
right: f32 = 0

display: c.int

image: rl.Image
texture: rl.Texture
starTexture: rl.Texture
