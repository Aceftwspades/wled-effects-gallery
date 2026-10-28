// hexagon map by nayk - https://www.shadertoy.com/view/4fXczr - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: hexagon map (nayk)
// hexagon map by nayk
// https://www.shadertoy.com/view/4fXczr
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// origianls from  https://www.shadertoy.com/view/lXVSWt https://www.shadertoy.com/view/X3KXWt
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
float sdHexagon( in vec2 p, in float r ){
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    return length(p+sin(iTime)/10.)*sign(p.y);
}
void mainImage(out vec4 O, in vec2 I)
{
    vec2 uv = 10. * (2. * I - iResolution.xy) / iResolution.y;
    
    float sd = sdHexagon(uv,10.);
    float val = cos(length(uv) - 4. * iTime + cos(2. * iTime*0.1) * (iTime*0.1 + 3. * atan(uv.y, uv.x)));
    val = abs(val - 1.1);
    vec3 col =  ceil(val-sd) * clamp(abs(mod((0.25 * iTime + 0.318309886184 * atan(uv.y,uv.x))*10.0+vec3(1.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
    O = vec4(col,1.0);
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
