#version 460 compatibility

out vec2 texcoord;
out vec2 lightcoord;
out vec4 glcolor;
out vec3 normal;

const float lmult = 32.0 / 30.0;
const float lbias = -1.0 / 32.0;

void main()
{
	gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lightcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lightcoord = lightcoord * lmult + lbias;
    glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;
}
