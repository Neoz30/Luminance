#ifndef LIGHTING
#define LIGHTING
#include "utils.glsl"
#include "../settings.glsl"

uniform vec3 shadowLightPosition;
uniform vec3 camPosition;
uniform float sunAngle;

const float ambientStrength = LIGHTING_AMBIENT;
const float diffuseStrength = LIGHTING_DIFFUSE;
const float specularStrength = LIGHTING_SPECULAR;
const float shininess = LIGHTING_SHININESS;
const vec3 worldLightVector = mat3(gbufferModelViewInverse) * (0.01 * shadowLightPosition);

const float tau = 6.2831853;
const float sint = sin(tau * sunAngle);
const float dist = 1.0 / clamp(sint, 0.0, 1.0);
const vec3 sunlightColor = pow(vec3(0.95, 0.9, 0.8), vec3(dist));
const vec3 skylightColor = vec3(1.0, 2.0, 4.0) * abs(sint);
const vec3 blocklightColor = vec3(1.0, 0.65, 0.5);

vec3 phongLightColor(vec3 viewPos, vec3 normal, vec3 shadowColor)
{
	vec3 tweakshadow = vec3(0.0);
	if (dot(worldLightVector, normal) > 0.08)
		tweakshadow = shadowColor * 0.8 + 0.2;
	vec3 celestialColor = sunlightColor;
	vec3 ambient = skylightColor;
	if (sunAngle > 0.5)
	{
		ambient *= 0.1;
		celestialColor = vec3(0.1, 0.1, 0.1);
	}
	vec3 diffuse = clamp(dot(worldLightVector, normal), 0.0, 1.0) * celestialColor;
	vec3 cam2px = normalize(mat3(gbufferModelViewInverse) * viewPos - camPosition);
	vec3 reflection = normalize(reflect(worldLightVector, normal));
	vec3 specular = vec3(pow(clamp(dot(reflection, cam2px), 0.0, 1.0), shininess)) * celestialColor;
	return ambientStrength * ambient + (diffuseStrength * diffuse + specularStrength * specular) * tweakshadow;
}

vec3 blockLightColor(float brightness)
{
	return brightness * blocklightColor;
}

#endif