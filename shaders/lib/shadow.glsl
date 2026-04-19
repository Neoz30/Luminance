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

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

const mat4 viewToClip = shadowProjection * shadowModelView * gbufferModelViewInverse;

vec3 getShadow(vec3 viewPos, vec3 normal) {
	vec4 shadowClipPos = viewToClip * vec4(viewPos, 1.0);
	normal = (viewToClip * vec4(normal, 1.0)).xyz;
	shadowClipPos.z -= 5e-2 * f(shadowClipPos.xy) + 5e-4;

	vec3 shadowAccumaltor = vec3(0.0);
	for (int x = -SHADOW_RANGE; x <= SHADOW_RANGE; x++)
	{
		for (int y = -SHADOW_RANGE; y <= SHADOW_RANGE; y++)
		{
			vec4 offsetShadowClipPos = shadowClipPos + vec4(vec2(x, y) * SHADOW_RADIUS / float(SHADOW_RANGE * 2048), 0.0, 0.0);
			offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
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