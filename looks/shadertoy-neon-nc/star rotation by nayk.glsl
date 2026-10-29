// star rotation by nayk - https://www.shadertoy.com/view/Xcsyz4 - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: star rotation (nayk)
// star rotation by nayk
// https://www.shadertoy.com/view/Xcsyz4
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// star
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)
float happy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
 
void mainImage(out vec4 O, vec2 C)
{
vec2 uv = ( C - .5*iResolution.xy ) / iResolution.y;
 uv.x+=0.3*cos(iTime);
        uv.y+=0.3*sin(iTime);
    O=vec4(0);
    vec3 p,r=iResolution,n=vec3(-.5,-.707,.5),
    d=normalize(vec3((C-.5*r.xy),r.y));  
    for(float i=0.,e,g=0.;
        ++i<99.;
        O.xyz+=mix(vec3(1),H(length(p)*.5+iTime*0.),.7)*.05*exp(-.13*i*i*e)
    )
    {
        p=g*d;
       
       p.x+=3.*cos(iTime);
        p.y+=3.*sin(iTime);
        p.z-=10.;
         p.xz*=mat2(cos(iTime), sin(iTime), -sin(iTime),cos(iTime));
          p.yz*=mat2(cos(iTime), sin(iTime), -sin(iTime),cos(iTime));
        p=R(p,normalize(vec3(-1,10,2)),-iTime*3.0);
        for(int j=0;j<15;j++)
        
             p.zy=abs((p.zy)),
            p.xy=abs((p.xy)),
            p-=2.*min(fract(p.x+p.z),dot(p,n))*n;
        p.z=fract(log(p.z)+iTime*3.5)-.5;
        g+=e=abs(min(length(p.yz),length(p.xz))-.03)+.001;
    }
    
    
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1 
    O*= vec4(happy_star(uv, anim) * vec3(0.35,0.2,.15)*3.1, 1.0);
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
