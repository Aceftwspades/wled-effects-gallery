// NAME: Spark fountain
// Spark fountain - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// sparks thrown from the middle, each as far as its band of the spectrum is loud, at the music's pace
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
float hash(float n) { return fract(sin(n * 91.345) * 47453.5453); }
void mainImage(out vec4 o, in vec2 f) {
    vec2 p = centred(f);
    vec4 last = texture(iChannel0, uv_of(p * (1.0 - 0.016 * K)));
    float ph = texture(iChannel0, vec2(0.5)).a + iTimeDelta * (0.25 + 1.6 * iLevel * REACT);
    vec3 col = last.rgb * pow(0.93, K);
    for (int i = 0; i < 14; i++) {
        float fi = float(i);
        float a = fi * 2.39996 + ph * 0.35;
        float reach = 0.16 + 0.50 * SPEC(0.03 + fi / 14.0 * 0.7) * REACT;
        float r = fract(ph * (0.6 + 0.5 * hash(fi)) + hash(fi + 7.0)) * reach;
        float d = length(p - r * vec2(cos(a), sin(a)));
        col = max(col, pal(fi / 14.0 + iTime * 0.03) * smoothstep(0.035, 0.008, d));
    }
    o = vec4(col, mod(ph, 1000.0));
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
void mainImage(out vec4 o, in vec2 f) {
    o = vec4(texture(iChannel0, f / iResolution.xy).rgb, 1.0);
}
