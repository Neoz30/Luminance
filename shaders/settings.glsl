#ifndef SETTINGS_GLSL
#define SETTINGS_GLSL

// Water Parameters
#define WAVE_AMPLITUDE 0.1 // [0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1]

#define FOG 0 // [0 1]

#define SHADOW_MAP 2048 // [256 512 1024 2048 4096 8192]
#define SHADOW_RANGE 0 // [0 1 2 3]
#define SHADOW_RADIUS 0.01 // [0.01 0.1 0.5 1.0]

#define LIGHTING_AMBIENT 0.2 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define LIGHTING_DIFFUSE 1.15 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define LIGHTING_SPECULAR 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define LIGHTING_SHININESS 16 // [4 8 16 32 64]

#endif