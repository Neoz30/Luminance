#version 460 compatibility
#include "/lib/utils.glsl"
#include "/lib/shadow.glsl"
#include "/lib/lighting.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main()
{
	float depth = texture2D(depthtex0, texcoord).r;
	color = texture2D(colortex0, texcoord);
	vec2 lightcoord = texture2D(colortex1, texcoord).rg;
	vec3 normal = texture(colortex2, texcoord).rgb * 2.0 - 1.0;
	if (length(normal) >= 1.1)
		return ;

	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, vec3(texcoord, depth) * 2.0 - 1.0);
	vec3 shadow = getShadow(viewPos, normal);

	color.rgb = pow(color.rgb, vec3(2.2));
	color.rgb *= phongLightColor(viewPos, normal, shadow) * lightcoord.g + blockLightColor(lightcoord.r);
	color.rgb = pow(color.rgb, vec3(1.0 / 2.2));
}
