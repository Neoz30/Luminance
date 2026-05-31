#version 460 compatibility

uniform sampler2D texture;
uniform float alphaTestRef;
uniform vec3 shadowLightPosition;
uniform vec4 entityColor;

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
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	lightmapData = vec4(lightcoord, 0.0, 1.0);
	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
}
