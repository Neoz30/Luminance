#version 460 compatibility

uniform sampler2D texture;
uniform float alphaTestRef;
uniform int renderStage;
uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;

in vec2 texcoord;
in vec2 lightcoord;
in vec4 glcolor;
in vec3 normal;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

void main()
{
    color = glcolor * texture2D(texture, texcoord);
	if (color.a < alphaTestRef)
		discard ;
	lightmapData = vec4(lightcoord, 0.0, 1.0);
	if (renderStage == MC_RENDER_STAGE_PARTICLES)
		encodedNormal = vec4((gbufferModelViewInverse * vec4(shadowLightPosition, 1.0) * 0.01) * 0.5 + 0.5);
	else
		encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
}
