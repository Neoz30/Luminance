#ifndef SHADOW
#define SHADOW

#include "utils.glsl"
#include "distort.glsl"
#include "lighting.glsl"
#include "../settings.glsl"

#define SHADOW_SAMPLES 4 * SHADOW_RANGE * (SHADOW_RANGE + 1) + 1

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 eyePosition;

uniform vec3 cameraPosition;
uniform float shadowAngle;

const mat4 viewToClip = shadowProjection * shadowModelView * gbufferModelViewInverse;

bool shadow_checkboard(vec3 viewPos)
{
	vec4 shadowClipPos = viewToClip * vec4(viewPos, 1.0);
	shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz);
	vec2 shadowUV = ((shadowClipPos.xy / shadowClipPos.w) * 0.5 + 0.5) * vec2(SHADOW_MAP) / 1;

	return ((int(floor(shadowUV.x)) + int(floor(shadowUV.y))) % 2 == 0);
}

vec3 getShadow(vec3 viewPos, vec3 normal) {
	vec4 shadowClipPos = viewToClip * vec4(viewPos, 1.0);
	float cosa = min(dot(normal, shadowLightPosition * 0.01), 0.9996);
	float depthBias = 16.0 * abs(sqrt(1.0 - cosa * cosa) / (cosa * SHADOW_MAP));

	vec3 shadowAccumaltor = vec3(0.0);
	for (int x = -SHADOW_RANGE; x <= SHADOW_RANGE; x++)
	{
		for (int y = -SHADOW_RANGE; y <= SHADOW_RANGE; y++)
		{
			vec4 offsetShadowClipPos = shadowClipPos + vec4(vec2(x, y) * SHADOW_RADIUS / float(SHADOW_RANGE * 2048), 0.0, 0.0);
			offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
			offsetShadowClipPos.z -= depthBias * (0.925 * f(shadowClipPos.xy) + 0.075);
			vec3 shadowScreenPos = (offsetShadowClipPos.xyz / offsetShadowClipPos.w) * 0.5 + 0.5;

			float transparentShadow = step(shadowScreenPos.z, texture2D(shadowtex0, shadowScreenPos.xy).r);
			if (transparentShadow == 1.0)
			{
				shadowAccumaltor += vec3(1.0);
				continue ;
			}
			float opaqueShadow = step(shadowScreenPos.z, texture2D(shadowtex1, shadowScreenPos.xy).r);
			if (opaqueShadow == 0.0)
				continue ;
			vec4 shadowColor = texture2D(shadowcolor0, shadowScreenPos.xy);
			shadowAccumaltor += shadowColor.rgb * (1.0 - shadowColor.a);
		}
	}
	return (shadowAccumaltor / float(SHADOW_SAMPLES));
}

#endif