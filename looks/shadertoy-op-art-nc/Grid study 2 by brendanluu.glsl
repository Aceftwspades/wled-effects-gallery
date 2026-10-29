// Grid study 2 by brendanluu - https://www.shadertoy.com/view/MfscRB - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: Grid study 2 (brendanluu)
// jul172024  by brendanluu
// https://www.shadertoy.com/view/MfscRB
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// bruh
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
vec3 palette(float t) {
    vec3 a = vec3(0.686,0.071,0.071);
    vec3 b = vec3(1.000,0.639,0.851);
    vec3 c = vec3(0.745,0.557,0.686);
    vec3 d = vec3(1.000,0.702,0.831);
    
    return a + b*cos(6.28318*(c*t+d) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y; 
    vec2 uv0 = uv;
    
    uv = fract(uv * 2.0) -0.5;
   
    float d = length(uv);
    
    vec3 col = palette(d + length(uv0));
        
    d = cos(d/0.8 + (iTime)/1.25)/90.;
    d = abs(d);
    
    d = 0.003 / d;
    
    col *= d;
    
    fragColor = vec4(col, 1.0);
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
