// NAME: Spectrum rings
// Spectrum rings - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// nine rings, each pushed out by its band of the spectrum, their dashes turning at the mid's pace
// Written for the studio's VJ, with an AI (Claude): it reads the studio's sound - iBass, iMid, iTreble,
// iLevel, iBeat, the spectrum and the wave on the sound channel - and the deck's amount (iAmount) is how
// hard the music moves it.
//@ common
#define SPEC(x) texture(iChannel1, vec2(clamp(x, 0.0, 1.0), 0.25)).r
#define WAVE(x) (texture(iChannel1, vec2(clamp(x, 0.0, 1.0), 0.75)).r * 2.0 - 1.0)
#define REACT (0.35 + 1.3 * iAmount)
#define K (iTimeDelta * 30.0)
vec3 pal(float t) { return 0.5 + 0.5 * cos(6.2832 * (t + vec3(0.0, 0.33, 0.67))); }
mat2 rot(float a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }
vec2 centred(vec2 f) { return (f - 0.5 * iResolution.xy) / iResolution.y; }
vec2 uv_of(vec2 p) { return (p * iResolution.y + 0.5 * iResolution.xy) / iResolution.xy; }
//@ buffer A
//@ iChannel0 = A
//@ iChannel1 = sound
//@ iChannel2 = none
//@ iChannel3 = none
void mainImage(out vec4 o, in vec2 f) {
    float ph = texture(iChannel0, vec2(0.5)).a;
    o = vec4(0.0, 0.0, 0.0, mod(ph + iTimeDelta * (0.15 + 1.8 * iMid * REACT), 1000.0));
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = sound
//@ iChannel2 = none
//@ iChannel3 = none
void mainImage(out vec4 o, in vec2 f) {
    vec2 p = centred(f);
    float ph = texture(iChannel0, vec2(0.5)).a;
    float r = length(p), ang = atan(p.y, p.x) / 6.2832 + 0.5;
    vec3 col = vec3(0.0);
    for (int i = 0; i < 9; i++) {
        float fi = float(i);
        float rr = 0.045 + fi * 0.052 + 0.055 * SPEC(0.03 + fi / 9.0 * 0.7) * REACT;
        float dash = smoothstep(0.42, 0.30, abs(fract(ang * (3.0 + fi) + ph * (mod(fi, 2.0) * 2.0 - 1.0) * 0.35) - 0.5));
        col = max(col, pal(fi / 9.0 + iTime * 0.04) * smoothstep(0.020, 0.004, abs(r - rr)) * (0.3 + 0.7 * dash));
    }
    o = vec4(col, 1.0);
}
