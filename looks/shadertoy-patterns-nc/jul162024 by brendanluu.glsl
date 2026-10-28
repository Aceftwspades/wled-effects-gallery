// jul162024 by brendanluu - https://www.shadertoy.com/view/XcXyWM - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: jul162024 (brendanluu)
// jul162024 by brendanluu
// https://www.shadertoy.com/view/XcXyWM
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// y'all need moire?
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
vec3 palette(float t) {
    vec3 a = vec3(0.616, 0.157, 0.106);
    vec3 b = vec3(1.000, 0.639, 0.851);
    vec3 c = vec3(0.310, 0.012, 0.216);
    vec3 d = vec3(1.000, 0.439, 0.682);

    return a + b * cos(6.28318 * (c * t + d));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    float d = length(uv);

    // Base resolution
    vec2 baseResolution = vec2(1280.0, 720.0);

    // Calculate resolution factor
    float resolutionFactor = length(iResolution.xy / baseResolution);

    // Adjust time relative to the resolution
    float adjustedTime = iTime + 200.0 * resolutionFactor;

    vec3 col = palette(d * adjustedTime * 69.0);

    d = cos(d * 1.3 + (adjustedTime * 0.55)) / 8.0;
    d = abs(d);

    d = 0.035 / d;

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
