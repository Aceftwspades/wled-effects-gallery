// Chromatin by wyatt - https://www.shadertoy.com/view/XffyDH - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: Chromatin (wyatt)
// Chromatin by wyatt
// https://www.shadertoy.com/view/XffyDH
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// ..
//@ common
#define R iResolution.xy
#define Main void mainImage(out vec4 Q, in vec2 U) 
#define ei(a) mat2(cos(a),sin(a),-sin(a),cos(a))
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
float map (vec3 p) {
    
    vec2 u = vec2(length(p.xy)-1.,p.z);
    float a = 0.;
    if (length(p.xy)>0.) a = atan(p.y,p.x);
    u *= ei(a);
    for (float i = 0.; i < 7.; i++) {
        u = abs(u*ei(i*i*i*a+.1*i*i*i*i*iTime))-.3*exp(-.9*i);
    }

    return length(u)-.0003;

}
vec3 normal (vec3 p) {
    vec2 e = vec2(1e-3,0);
    return normalize(
        vec3(
            map(p+e.xyy)-map(p-e.xyy),
            map(p+e.yxy)-map(p-e.yxy),
            map(p+e.yyx)-map(p-e.yyx)
        )
    );

}
Main {
    Q = vec4(0);
    #define AA 1
    for (int x = 0; x < AA; x++)
    for (int y = 0; y < AA; y++){
        vec3 p = vec3(0,0,-1);
        vec3 d = normalize(vec3(2.*(U+vec2(x,y)/float(AA)-.5*R)/R.y,1));
        p.xz *= ei(.1*iTime);
        d.xz *= ei(.1*iTime);
        p.yz *= ei(.1*iTime);
        d.yz *= ei(.1*iTime);

        for (float i = 0.; i < 70.; i++) {

            p += .8*d*map(p);

        }
        vec3 li = vec3(0);
        vec3 n = normal(p);
        d = normalize(li-p);
        p += 3e-3*d;
        if (map(p) > .01) ;else{
        for (float i = 0.; i < 30.; i++) {

            p += .8*d*min(map(p),length(p-li)-.01);

        }
        Q.xyz += 1./float(AA*AA)*(0.5+0.5*n)*vec3(2,.5,1.5)*exp(-2.*length(p-li));
        }
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
