#ifndef DISTORT
#define DISTORT

const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = true;

float f(vec2 v) {
	return (length(v));
}

vec3 distortShadowClipPos(vec3 shadowClipPos) {
	float distortionFactor = 0.925 * f(shadowClipPos.xy) + 0.075;
	shadowClipPos.xy /= distortionFactor;
	return shadowClipPos;
}

#endif