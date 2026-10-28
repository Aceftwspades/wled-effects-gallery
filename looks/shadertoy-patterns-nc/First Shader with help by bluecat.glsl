// First Shader with help by bluecat - https://www.shadertoy.com/view/lclyWr - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: First Shader with help (bluecat)
// First Shader with help by bluecat
// https://www.shadertoy.com/view/lclyWr
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// first shader ever with tutorial help: https://www.youtube.com/watch?v=f4s1h2YETNY
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
vec3 palette(float t) 
{
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263,0.416,0.557);
    
    return a + b*cos( 6.28318*(c*t*d) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);
    
    for (float i = 0.0; i < 3.0; i++) 
    {
        uv = fract(uv * 1.5) - 0.5;
        float d = length(uv) * exp(-length(uv0));
        
        vec3 col = palette(length(uv0) + i*.5 + iTime*.4);
        
        d = sin(d*8. + iTime)/8.;
        d = abs(d);
        
        d = pow(0.01 / d, 1.2);
        
        col *= d;
        
        finalColor += col * d;
    }
    
    fragColor = vec4(finalColor, 1.0);
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
