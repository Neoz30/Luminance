#version 460 compatibility
#include "/lib/distort.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform vec3 shadowLightPosition;
uniform float viewWidth;
uniform float viewHeight;
uniform float sunAngle;
uniform vec3 camPosition;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

const float tau = 6.2831853;

const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
const vec3 sunlightColor = vec3(0.99, 0.98, 0.83);
const vec3 moonlightColor = vec3(0.05, 0.05, 0.44);
const vec3 ambientColor = vec3(0.1);

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

vec4 getNoise(vec2 coord){
	ivec2 screenCoord = ivec2(coord * vec2(viewWidth, viewHeight));
	ivec2 noiseCoord = screenCoord % 64;
	return texelFetch(noisetex, noiseCoord, 0);
}

vec3 getShadow(vec3 shadowScreenPos){
	float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);
	if(transparentShadow == 1.0)
		return vec3(1.0);

	float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r);
	if(opaqueShadow == 0.0)
		return vec3(0.0);

	vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);
	return shadowColor.rgb * (1.0 - shadowColor.a);
}

vec3 getSoftShadow(vec4 shadowClipPos){
	float noise = getNoise(texcoord).r;

	float theta = noise * radians(360.0);
	float cosTheta = cos(theta);
	float sinTheta = sin(theta);

	mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);

	vec3 shadowAccum = vec3(0.0);
	const int samples = 25;

	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			vec2 offset = vec2(x, y) * 0.375;
			offset = rotation * offset;
			offset /= 2048;
			vec4 offsetShadowClipPos = shadowClipPos + vec4(offset, 0.0, 0.0);
			offsetShadowClipPos.z -= 0.001;
			offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
			vec3 shadowNDCPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w;
			vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
			shadowAccum += getShadow(shadowScreenPos);
		}
	}

	return shadowAccum / float(samples);
}

void main() {
	float depth = texture(depthtex0, texcoord).r;
	color = texture(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));
	if (depth == 1.0)
		return ;
	vec2 lightmap = texture(colortex1, texcoord).rg;
	vec3 normal = normalize((texture(colortex2, texcoord).rgb - 0.5) * 2.0);

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);

	shadowClipPos.z -= 1e-3;
	shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz);
	vec3 shadowNDCPos = shadowClipPos.xyz / shadowClipPos.w;
	vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;

	vec3 shadow = getShadow(shadowScreenPos);

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	//float t = clamp(sin(tau * sunAngle), 0.1, 1.0);

	vec3 blocklight = lightmap.r * blocklightColor;
	vec3 skylight = lightmap.g * skylightColor;
	vec3 ambient = ambientColor;
	vec3 sunlight = sunlightColor * clamp(dot(worldLightVector, normal), 0.0, 1.0) * lightmap.g * shadow;

	vec3 specular = vec3(0.0);
	if (shadow != 0.0)
	{
		vec3 reflection = normalize(reflect(worldLightVector, normal));
		vec3 cam2px = normalize(mat3(gbufferModelViewInverse) * viewPos - camPosition);
		specular = vec3(pow(clamp(dot(reflection, cam2px), 0.0, 1.0), 16));
	}

	color.rgb *= blocklight + skylight + ambient + sunlight + specular;
}