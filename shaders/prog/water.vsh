#version 460 compatibility
#include "../settings.glsl"

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

in vec2 mc_Entity;

out vec2 texcoord;
out vec2 lightcoord;
out vec4 glcolor;
out vec3 normal;

out vec3 viewPos;

const float lmult = 32.0 / 30.0;
const float lbias = -1.0 / 32.0;

void main()
{
    vec3 pos = gl_Vertex.xyz;
    vec3 position = pos + cameraPosition;

	normal = gl_Normal;

    if (mc_Entity.x == 1)
	{
        pos.y += WAVE_AMPLITUDE * sin(position.x + 0.35 * position.z + frameTimeCounter);
		normal.xz -= WAVE_AMPLITUDE * cos(position.x + 0.35 * position.z + frameTimeCounter);
		normal.y = sqrt(1 - normal.x * normal.x - normal.z * normal.z);
	}
	normal = gl_NormalMatrix * normal;

    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos, 1.0);
	viewPos = (gl_ModelViewMatrix * vec4(pos, 1.0)).xyz;

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lightcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lightcoord = lightcoord * lmult + lbias;
    glcolor = gl_Color;
}
