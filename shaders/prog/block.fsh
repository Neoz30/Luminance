#version 460 compatibility
#include "../lib/utils.glsl"

uniform sampler2D texture;
uniform sampler2D depthtex0;

uniform float alphaTestRef;
uniform int renderStage;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;

uniform float viewWidth;
uniform float viewHeight;
uniform int blockEntityId;
uniform float frameTimeCounter;

in vec2 texcoord;
in vec2 lightcoord;
in vec4 glcolor;
in vec3 normal;

in vec3 viewPos;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

vec2 rotate90(vec2 uv, int n)
{
	n %= 4;
	while (n-- > 0)
		uv = vec2(uv.y, -uv.x);
	return (uv);
}

vec3 colors[4] = {
	vec3(0.33, 0.65, 0.57),
	vec3(0.10, 0.59, 0.65),
	vec3(0.50, 0.41, 0.66),
	vec3(0.68, 0.76, 0.44)
};

vec4 endPortalColor()
{
	float offset = 0.01 * frameTimeCounter;
	vec3 viewDir = mat3(gbufferModelViewInverse) * viewPos;
	vec3 worldPos = viewDir + gbufferModelViewInverse[3].xyz + cameraPosition;
	worldPos.xz *= 0.0625;
	viewDir.xz /= abs(viewDir.y);
	viewDir *= 0.0625;

	vec3 finalColor = vec3(0.0);
	vec2 layerUV = worldPos.xz + viewDir.xz * (abs(viewDir.y) + 0.2);
	for (int i = 0; i < 8; i++)
	{
		vec2 tmpLayerUV = rotate90(layerUV, i);
		finalColor += texture2D(texture, tmpLayerUV + vec2(0.0, offset)).r * colors[i % 4];
		layerUV += viewDir.xz * (i + 1);
	}
	return (vec4(finalColor, 1.0));
}

void main()
{
	if (blockEntityId != 3)
    	color = glcolor * texture2D(texture, texcoord);
	else
		color = endPortalColor();
	if (color.a < alphaTestRef)
		discard ;
	lightmapData = vec4(lightcoord, 0.0, 1.0);
	if (renderStage == MC_RENDER_STAGE_PARTICLES)
		encodedNormal = vec4(shadowLightPosition * 5e-3 + 0.5, 1.0);
	else
		encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
}
