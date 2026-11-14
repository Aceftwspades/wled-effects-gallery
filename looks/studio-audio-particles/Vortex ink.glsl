// NAME: Vortex ink
// Vortex ink - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// four drops of ink circling a whirlpool: the bass spins it, each drop as big as its band is loud
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
    vec2 p = centred(f);
    float ph = texture(iChannel0, vec2(0.5)).a + iTimeDelta * (0.30 + 1.2 * iLevel * REACT);
    float spin = (0.015 + 0.11 * iBass * REACT) * K * exp(-length(p) * 2.5);
    vec3 col = texture(iChannel0, uv_of(rot(spin) * p * (1.0 + 0.004 * K))).rgb * pow(0.983, K);
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        vec2 c = (0.27 + 0.12 * sin(ph * 0.7 + fi)) * vec2(cos(-ph * 0.5 + fi * 1.5708), sin(-ph * 0.5 + fi * 1.5708));
        float r = 0.035 + 0.095 * SPEC(0.03 + fi / 4.0 * 0.7) * REACT;
        col = max(col, pal(fi * 0.25 + iTime * 0.04) * smoothstep(r, r * 0.4, length(p - c)));
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
