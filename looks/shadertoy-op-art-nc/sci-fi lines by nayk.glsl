// sci-fi lines by nayk - https://www.shadertoy.com/view/lcscR4 - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: sci-fi lines (nayk)
// sci-fi lines by nayk
// https://www.shadertoy.com/view/lcscR4
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// originals https://www.shadertoy.com/view/mtyGWy https://www.shadertoy.com/view/DtGyWh https://www.shadertoy.com/view/7ldyWn
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)
float h(vec2 p)
{

	vec3 a  = fract(vec3(p.yxy) * .2031);
  
    a += dot(a+sin(iTime*0.000002), a.yzx+cos(iTime*0.002) + 33.33);
    
    return fract((a.x+sin(iTime*0.001) + a.y+sin(iTime*0.001)) * a.z+sin(iTime*0.0002));
}
vec3 palette( float t ) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263,0.416,0.557);

    return a + b*cos( 6.28318*(c*t+d) );
}
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
     vec2 p2 = C / 40.;
  
     vec2 uv = (C * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
  
    vec3 finalColor = vec3(0.0);
    
    for (float i = 0.0; i < 4.0; i++) {
        uv = fract(uv * 1.5) - 0.5;

        float d = length(uv) * exp(-length(uv0));

        vec3 col = palette(length(uv0) + i*.4 + iTime*0.4);

        d = sin(d*8. + iTime*002.)/8.;
        d = abs(d);

        d = pow(0.01 / d, 1.2);

        finalColor += col * d;
    }
  
    vec3 p,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    {
        p=g*d;
       
        a=20.;
        p=mod(p-a,a*2.)-a;
        s=3.;
        for(int i=0;i++<8;){
            p=.3-abs(p);
            
            p.x<p.z?p=p.zyx:p;
            p.z<p.y?p=p.xzy:p;
            p.y<p.x?p=p.zyx:p;
            
            s*=e=1.4+sin(iTime*.234)*.1;
            p=abs(p)*e-
                vec3(
                    2.+cos(iTime*.0+.5*cos(iTime*.0))*3.,
                    120,
                    3.+cos(iTime*.0)*5.
                 )+finalColor;
         }
 
         g+=e=length(p.yx*mat2(cos(iTime*0.51), sin(iTime*0.51), -sin(iTime*0.51),cos(iTime*0.51)))/s;
    }
      O*= vec4(step(abs(abs(fract(dot(vec2((floor(h(ceil(p2))*2.-.5)),1),p2))-.5)-.38),.06));
       O*= vec4(finalColor*20., 1.0);
      
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
