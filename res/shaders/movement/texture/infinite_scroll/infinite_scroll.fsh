#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_texCoord;

uniform sampler2D u_texture;
uniform vec2 u_time;

in vec2 u_r;



void main()
{
  gl_FragColor =  vec4(1.0, 1.0,1.0,1.0);//texture2D(u_texture, v_texCoord);
}