// black cube in  by nayk - https://www.shadertoy.com/view/4flyz4 - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: black cube in  (nayk)
// black cube in  by nayk
// https://www.shadertoy.com/view/4flyz4
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// original from gaz fractal
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
    vec3 p,r=iResolution,n=vec3(-.5,-.707,.5),
    d=normalize(vec3((C-.5*r.xy),r.y));  
    for(float i=0.,e,g=0.;
        ++i<99.;
        O.xyz+=mix(vec3(1),H(length(p)*.5+iTime*3.),.7)*.05*exp(-.03*i*i*e)
    )
    {
        p=g*d;
        p.z-=10.;
        p=R(p,normalize(vec3(-1,0,2)),iTime*.5);
        for(int j=0;j<4;j++)
            p.xy=abs(ceil(p.xy)),
            p-=2.*min(0.,dot(p,n))*n;
        p.z=fract(log(p.z)-iTime*.5)-.5;
        g+=e=abs(min(length(p.yz),length(p.xz))-.03)+.001;
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
