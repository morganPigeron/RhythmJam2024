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
panVertical: f32
sound: rl.Sound
playing := false

sampleCount: u32 = 0
samples := make([]f32, 4096) //FIXME set this as needed and delete it
sampleLeft := make([]f32, 2048) //FIXME set this as needed and delete it
sampleRight := make([]f32, 2048) //FIXME set this as needed and delete it

left: f32 = 0
right: f32 = 0

display: c.int

image: rl.Image
texture: rl.Texture
starTexture: rl.Texture
