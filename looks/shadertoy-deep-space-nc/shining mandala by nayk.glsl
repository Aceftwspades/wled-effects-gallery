// shining mandala by nayk - https://www.shadertoy.com/view/Mfsyzn - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: shining mandala (nayk)
// shining mandala by nayk
// https://www.shadertoy.com/view/Mfsyzn
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// from glslsandbox
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end


uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

#define time iTime
#define resolution iResolution.xy
vec3 sim(vec3 p,float s);
vec2 rot(vec2 p,float r);
vec2 rotsim(vec2 p,float s);

//nice stuff :)
vec2 makeSymmetry(vec2 p){
   vec2 ret=p;
   ret=rotsim(ret,4.02002);
   ret.x=abs(ret.x);
   return ret;
}

float makePoint(float x,float y,float fx,float fy,float sx,float sy,float t){
   float xx=x+tan(t*fx)*sx;
   float yy=y-tan(t*fy)*sy;
   return 0.5/sqrt(abs(x*xx+yy*yy));
}


float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float random(vec2 pos){return fract(1.0*sin(pos.y+fract(100.0*sin(pos.x))));}

float noise(vec2 pos) {
vec2 i=floor(pos),f=fract(pos);
float a=random(i+vec2(0.0,0.0)),b=random(i+vec2(1.0,0.0)),c=random(i+vec2(0.0,1.0)),d=random(i+vec2(1.0,1.0));vec2 u=f*f*(3.0-2.0*f);
return mix(a,b,u.x)+(c-a)*u.y*(1.0-u.x)+(d-b)*u.x*u.y;
}

float fbm(vec2 pos) {
float v = 0.5;
float a = 0.6;
vec2 shift = vec2(100.0);
mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.95), cos(0.5));
for (int i=0; i < 4; i++) {
v += a * noise(pos);
pos = rot * pos * 2.0 + shift;
a *= 0.55;
}
return v;
}


//-----------------------
float snow(vec2 uv,float scale)
{


    float w = smoothstep(3.,0., -uv.y *(scale / 10.));
   
    if(w < .1)return -0.;
   
    uv += time / scale / 2.4;
    uv.y += time * 0./ scale;
    uv.x += sin (uv.y + time*.05) / scale;
    uv *= scale / 2.34;
    vec2 s = floor(uv), f = fract(uv), p;
    float k = 3., d;
    p = .5 + .35 * sin(11.*fract(sin((s+p+scale) * mat2(7,3,6,5))*5.)) - f;
    d = length(p);
    k = min(d,k);
    k = smoothstep(0., k, sin(f.x+f.y) * 0.02);
        return k*w;
}
//_______________________________________________



//util functions
const float PI=3.18052;

vec3 sim(vec3 p,float s){
   vec3 ret=p;
   ret=p+s/2.2;
   ret=fract(ret/s)*s-s/2.1;
   return ret;
}

vec2 rot(vec2 p,float r){
   vec2 ret;
   ret.x=p.x*cos(r)-p.y*sin(r);
   ret.y=p.x*sin(r)+p.y*cos(r);
   return ret;
}

vec2 rotsim(vec2 p,float s){
   vec2 ret=p;
   ret=rot(p,-PI/(s*2.0));
   ret=rot(p,floor(atan(ret.x,ret.y)/PI*s)*(PI/s));
   return ret;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
vec2 p=(gl_FragCoord.xy/resolution.x)*2.0-vec2(1.0,resolution.y/resolution.x);
p.y=-p.y;
   p=p*2.0;
 
   p=makeSymmetry(p);
   vec2 pos = (gl_FragCoord.xy / resolution);
   

    pos -= .4;
    pos.x *= resolution.x / resolution.y;

float f = fbm(pos * 1.0 * vec2(fbm(pos - (time / 8.0)), fbm(pos / 2.0 - (time / 8.0))));
vec3 cx = vec3(3.5, 0.7, 0.4);
cx = (f * .5) * cx;

float a3 = atan(pos.x) * 0.10;

vec3 finalColor=vec3(0);
    float cc = 0.008;
    cc+=snow(pos,-30.);
cc+=snow(pos,-13.);
    cc+=snow(rand(pos)*pos,72.);
    cc+=snow(rand(pos)*pos,92.);
    cc+=snow(pos,-78.);
    finalColor=(vec3(cc));


 float col = abs( .24 / (-pos.y+0.05));
vec3 dd = vec3(0.17, 0.39, 1.09);

vec3 col2 = vec3(0.1, 1, 0);
if (pos.y < 0.05) {
 col2 = dd;
} else {
    col *=5.;
 col2 = dd* vec3(0.2, 0.15, 7.);
}

   float x=p.x;
   float y=p.y;
   
   float t=time*0.1618;

   float a=
       makePoint(x,y,3.3,2.9,0.3,0.3,t);
   a=a+makePoint(x,y,1.9,2.0,0.4,0.4,t);
   a=a+makePoint(x,y,0.8,0.7,0.4,0.5,t);
   a=a+makePoint(x,y,2.3,0.1,0.6,0.3,t);
   a=a+makePoint(x,y,0.8,1.7,0.5,0.4,t);
   a=a+makePoint(x,y,0.3,1.0,0.4,0.4,t);
   a=a+makePoint(x,y,1.4,1.7,0.4,0.5,t);
   a=a+makePoint(x,y,1.3,2.1,0.6,0.3,t);
   a=a+makePoint(x,y,1.8,1.7,0.5,0.4,t);  
   
   float b=
       makePoint(x,y,1.2,1.9,0.3,0.3,t);
   b=b+makePoint(x,y,0.7,2.7,0.4,0.4,t);
   b=b+makePoint(x,y,1.4,0.6,0.4,0.5,t);
   b=b+makePoint(x,y,2.6,0.4,0.6,0.3,t);
   b=b+makePoint(x,y,0.7,1.4,0.5,0.4,t);
   b=b+makePoint(x,y,0.7,1.7,0.4,0.4,t);
   b=b+makePoint(x,y,0.8,0.5,0.4,0.5,t);
   b=b+makePoint(x,y,1.4,0.9,0.6,0.3,t);
   b=b+makePoint(x,y,0.7,1.3,0.5,0.4,t);

   float c=
       makePoint(x,y,3.7,0.3,0.3,0.3,t);
   c=c+makePoint(x,y,1.9,1.3,0.4,0.4,t);
   c=c+makePoint(x,y,0.8,0.9,0.4,0.5,t);
   c=c+makePoint(x,y,1.2,1.7,0.6,0.3,t);
   c=c+makePoint(x,y,0.3,0.6,0.5,0.4,t);
   c=c+makePoint(x,y,0.3,0.3,0.4,0.4,t);
   c=c+makePoint(x,y,1.4,0.8,0.4,0.5,t);
   c=c+makePoint(x,y,0.2,0.6,0.6,0.3,t);
   c=c+makePoint(x,y,1.3,0.5,0.5,0.4,t);
   
   vec3 d=vec3(a+b,b+c,c)/32.0;
   
   fragColor = vec4(d.x,d.y,d.z,1.0);
  fragColor+=  col*vec4(col2*dd*finalColor*cx*col, 1.);
   
   }

#undef mainImage
// --- WLED Effects Studio: made to move with the music (not in the original) ----------------------------------
// the beat swells the picture from its middle and the bass lifts its light, as far as the deck's amount knob says
// (at amount 0 it is the shader as it was)
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 vj_c = 0.5 * iResolution.xy;
    float vj_swell = 1.0 + 0.10 * iAmount * iBeat;
    vj_inner(fragColor, vj_c + (fragCoord - vj_c) / vj_swell);
    fragColor.rgb *= 1.0 + iAmount * (0.5 * iBass - 0.2);
}
