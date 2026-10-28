// manada mandala dala by nayk - https://www.shadertoy.com/view/lcXyRS - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: manada mandala dala (nayk)
// manada mandala dala by nayk
// https://www.shadertoy.com/view/lcXyRS
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// sources  https://www.shadertoy.com/view/4tyfWy https://www.shadertoy.com/view/fdy3WG https://glslsandbox.com/e#78073.0
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)
uniform float time;

#define time iTime
#define resolution iResolution.xy
float happy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
 
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
     vec2 uv = ( C - .5*iResolution.xy ) / iResolution.y;
    vec2 p2 = (C.xy * 2.0 - resolution) /min(resolution.x, resolution.y);
	float l = 0.3 * abs(cos(time)) / length(p2);
	vec3 Color = vec3(l, 0.5, 0.7);
	float f = 0.0;
	for(float i = 0.0; i < 20.0; i++)
	{
		float s = sin(time + i * 1.0) * 0.5;
		float c = cos(time + i * 1.0) * 0.5;
        f += 0.0025 / abs(length(p2 + vec2(c, s)) - 0.5);
		f += 0.0015 / abs(length(p2 - vec2(c, s)) - 1.0);
		f += 0.00215 / abs(length(p2 + vec2(c, s)) - 0.5);
	}
	

    vec3 p,r=iResolution,
    d=normalize(vec3((C-.5*r.xy)/r.y,1));  
    for(
        float i=0.,g=0.,e,s;
        ++i<99.;
        O.rgb+=mix(r/r,H(log(s)),.7)*.08*exp(-i*i*e))
    {
        p=g*d;
       
        p.z-=.6;

        s=3.;
        for(int j=0;j++<8;)
            p=abs(p+vec3(Color * f)),p=p.x<p.y?p.zxy:p.zyx,
              p=abs(p),p=p.x<p.y?p.zxy:p.zyx,
              
            s*=e=1.8/min(dot(p,p),1.3),
            p=p*e-vec3(12,3,3);
        g+=e=length(p.xz)/s;
  
    }
    O=pow(O,vec4(5));
    uv *= 2.0 * ( cos(iTime * 2.0) -2.5); // scale
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1 
    O*= vec4(happy_star(uv, anim) * vec3(0.35,0.2,0.15), 1.0);
    O+= vec4(happy_star(uv, anim) * vec3(0.35,0.2,0.35)*0.1, 1.0);
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
