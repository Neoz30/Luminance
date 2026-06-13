#version 460 compatibility
#include "lib/utils.glsl"
#include "lib/lighting.glsl"
#include "settings.glsl"

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform float far;
uniform float fogStart;
uniform float fogEnd;
uniform float fogDensity;
uniform vec3 fogColor;


in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

uniform sampler2D shadowtex0;

void main() {
	color = texture2D(colortex0, texcoord);
	#if FOG
	float depth = texture2D(depthtex0, texcoord).r;
	if (depth == 1.0)
		return ;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, vec3(texcoord, depth) * 2.0 - 1.0);
	float t = clamp((length(viewPos) - fogStart) / (fogEnd - fogStart), 0.0, 1.0);
	color = mix(color, vec4(fogColor, 1.0), t * pow(1 - fogDensity, 1 - t));
	#endif
}