#version 460 compatibility
#include "../lib/lighting.glsl"

uniform int renderStage;
uniform vec3 upPosition;
uniform vec3 fogColor;
uniform vec3 skyColor;

in vec3 viewPos;
in vec4 glcolor;

/* RENDERTARGETS: 0,2 */
layout(location = 0) out vec4 color;
layout(location = 2) out vec4 normal;

const vec3 lightDir = mat3(gbufferModelViewInverse) * (shadowLightPosition * 0.01);

void main()
{
	color = mix(vec4(fogColor, 1.0), vec4(skyColor, 1.0),
		sqrt(clamp(dot(normalize(viewPos), upPosition * 0.01), 0.0, 1.0)));
	if (renderStage == MC_RENDER_STAGE_STARS)
		color = glcolor;
	normal = vec4(vec3(0.5), 1.0);
}
