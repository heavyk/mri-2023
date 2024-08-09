attribute vec2 aTexCoord;
attribute vec2 aPosition;
                         
varying vec2 vTexCoord;
uniform mat3 uTrans;

void main() {
   vec3 homog = vec3(aPosition, 1);
   vec3 transformed = uTrans * homog;
   gl_Position = vec4(transformed.xy, 0, 1);
   
   vTexCoord = aTexCoord;
}