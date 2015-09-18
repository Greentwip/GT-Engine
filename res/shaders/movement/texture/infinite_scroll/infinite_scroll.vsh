attribute vec4 a_position;
attribute vec2 a_texCoord;

uniform vec2 u_time;
uniform float u_x;


#ifdef GL_ES
varying mediump vec2 v_texCoord;
#else
varying vec2 v_texCoord;
#endif

out vec2 u_r;

void main()
{
    gl_Position = CC_MVPMatrix * a_position;
    v_texCoord = a_texCoord;

    u_r = vec2(u_x, 0.0);
}