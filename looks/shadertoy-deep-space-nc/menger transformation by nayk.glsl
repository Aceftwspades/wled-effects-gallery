// menger transformation by nayk - https://www.shadertoy.com/view/4fXyRB - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: menger transformation (nayk)
// menger transformation by nayk
// https://www.shadertoy.com/view/4fXyRB
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// originals  https://glslsandbox.com/e#78381.0 https://www.shadertoy.com/view/fdy3WG
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end



#define time iTime
#define resolution iResolution.xy
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
float cube(vec3 p, vec3 s)
{
s+=R(s,normalize(vec3(1,1,1)),iTime);
  p =abs(p) - s;
  return max(max(p.x,p.y),p.z);
}

float crosscube(vec3 p, vec3 s)
{
 s=R(s,normalize(vec3(10,3,10)),iTime);
  vec3 a = vec3(s.x*1./3.,s.x*1./3.,s.x*4./3.);
  float d = cube(p,a.xyz);
  float d2 = cube(p,a.yzx);
  float d3 = cube(p,a.zxy);

  return min(min(d,d2),d3);
}

float menger(vec3 p, vec3 s)
{
  p=R(p,normalize(vec3(10,3,10)),iTime);
  float d = cube(p,s);
  float td = crosscube(p,s);
  d = max(d,-td);

for(int i = 0; i < 4; i++)
{
  s *= 1./3.;
  float m = s.x * 2.;
    p+=R(p,normalize(vec3(10,53,2)),iTime);
  p = mod(p-m*0.5,m)-m*0.5;
  p=R(p,normalize(vec3(23,2,1)),iTime);
  td = crosscube(p,s);
  d = max(d,-td);
}
  return d;
}

float map(vec3 p)
{
p=R(p,normalize(vec3(1,2,1)),iTime);
  float d = menger(p,vec3(1.));

  return d;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 p = (gl_FragCoord.xy * 2. - resolution.xy) / min(resolution.x,resolution.y);

  vec3 cp = vec3(0.,0.,5.);
  vec3 cd = vec3(0.,0.,-1.);
  vec3 cu = vec3(0.,1.,0.);
  vec3 cs = cross(cd,cu);
  float td = 1.;

  vec3 ray = normalize(p.x*cs+p.y*cu+cd*td);
  vec3 col = vec3(0.);
  float me = 0.;

  float d,t = 0.;
  vec3 rp = cp;
  for(int i = 0; i < 128; i++)
  {

      d = map(rp);
      
      me += exp(abs(d)*-0.2);
    if(d < 0.001)
    {
      break;
    }
    t += d;
    rp = cp + t * ray;
  }
  col = vec3(0.3,0.7,1.9)*me*0.05;
 fragColor = vec4(col,1.);
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
