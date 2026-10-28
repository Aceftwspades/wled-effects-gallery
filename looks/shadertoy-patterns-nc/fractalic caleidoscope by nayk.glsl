// fractalic caleidoscope by nayk - https://www.shadertoy.com/view/4fscRM - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: fractalic caleidoscope (nayk)
// fractalic caleidoscope by nayk
// https://www.shadertoy.com/view/4fscRM
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// originals https://www.shadertoy.com/view/DtGyWh https://www.shadertoy.com/view/MdXSzS
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(23,223,21))*2.5+.5)
#define time iTime
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    vec4 p2;
    vec2 uv = (C.xy / iResolution.xy) - .5;
	float t = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv.xy) + .07)) * 2.2;
	float si = sin(t);
	float co = cos(t);
	mat2 ma = mat2(co, si, -si, co);
    vec3 col = vec3(0);
    vec3 n1,q
    ,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1)); 
        
      vec2 resolution = iResolution.xy;
      vec2 p = 2.0*(C.xy / iResolution.xy )-1.0;
	vec3 Color = vec3(0.1, 0.3, 0.9);
	float col2 = -0.1;
	vec2 a = (gl_FragCoord.xy * 2.0 - resolution) / min(resolution, resolution.y);
    a*=ma;
	for(float i=0.0;i<126.0;i++)
	{
	  float si = sin(time + i * 0.05)/0.5;
	  float co = cos(time + i * 0.05)*0.5;
	  col2 += 0.01 / abs(length(a + vec2(si , co * si )) - 0.1);
	}
	for (int i = 0; i < 100; i++) {
		float lt = 0.01;
		float a = float(i);
		vec2 b = vec2(1.5*sin(time+a),0.8*sin(time*0.77+a)); 
          b*=ma;
		if (abs(p.x) < b.x && abs(p.y) < b.y) {
			if (abs(p.x) > b.x-lt || abs(p.y) > b.y-lt )
				 col = vec3(1);
		}
	}
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    {
        n1.zxy=g*d;
  
        a=20.;
        n1=mod(n1-a,a*2.)-a;
        s=7.;
        for(int i=0;i++<8;){
            n1=.3-abs(n1);
            
            n1.x<n1.z?n1=n1.zyx:n1;
            n1.z<n1.y?n1=n1.xzy:n1;
            n1.y<n1.x?n1=n1.zyx:n1;
            n1.xz*=ma;
            s*=e=1.4+sin(iTime*.234)*.1;
            n1=abs(n1+col)*e-
                vec3(
                    5.+cos(iTime*.3+.5*cos(iTime*.3))*3.,
                    120,
                    8.+cos(iTime*.5)*5.
                 )+col2;
         }
        g+=e=length(n1.yz)/s;
        

         g+=e=length(n1.yx)/s;
    }
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
