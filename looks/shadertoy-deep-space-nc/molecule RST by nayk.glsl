// molecule RST by nayk - https://www.shadertoy.com/view/4fscWN - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: molecule RST (nayk)
// molecule RST by nayk
// https://www.shadertoy.com/view/4fscWN
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// combination of https://www.shadertoy.com/view/4cXcWN and  https://www.shadertoy.com/view/DtGyWh
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    
    vec2 o_trn = ( C.xy - iResolution.xy*.5 ) / iResolution.yy;
    o_trn*=1.5;
    float n = (length(o_trn)-.5)/.5;
    
    float n_its = 33.; 
    float n_it_one_nor = 1./n_its;
    float n_tau = 6.2831;
    vec4 o_col = vec4(0.);
    for(float n_it_nor = 0.; n_it_nor<1.; n_it_nor+=n_it_one_nor){
    
        float n_radians = n_tau * n_it_nor*iTime;
        float n_radius = sin(iTime*0.5+n_it_nor*n_tau*3.)*.5*iTime*0.01;
        vec2 o_p = vec2(
            sin(n_radians), 
            cos(n_radians)
        )*n_radius;
        float n = length(o_trn-o_p);
        float n_circ_rad = (0.2*cos(iTime*.5+(n_it_nor*3.+.25)*n_tau)*iTime*0.01*.5+.5)*0.15;
        n = (n-n_circ_rad)/n_circ_rad;// signed distance field
        n = 1.-pow(abs(n), 1./5.);
        n = clamp(n, 0., 1.);
        vec4 o_c = vec4(n_it_nor, 1.-n_it_nor, fract(n_it_nor+.5), 1.);
        o_col += o_c*n;
        }
    vec3 n1,q,r=iResolution,
    
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    {
        n1=g*d;
     n1.xz*=mat2(cos(iTime),sin(iTime),-sin(iTime),cos(iTime) );
      n1.yz*=mat2(cos(iTime),sin(iTime),-sin(iTime),cos(iTime) );
        a=35.;
        n1=mod(n1-a,a*2.)-a;
           
        s=3.+(dot(d.z,d.y));
        for(int i=0;i++<8;){
            n1=.3-abs(n1);
           
            n1.x<n1.z?n1=n1.zyx:n1;
            n1.z<n1.y?n1=n1.xzy:n1;
            
            s*=e=1.4+sin(iTime*.234)*.1;
            n1=abs(n1)*e-
                vec3(
                    5.+cos(iTime*.103+.5*cos(iTime*.053))*3.,
                    120,
                    8.+cos(iTime*0.105)*5.
                 )*o_col.xyz;
         }
      g+=e=length(n1.yz+ceil(n1.y))/s;
     
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
