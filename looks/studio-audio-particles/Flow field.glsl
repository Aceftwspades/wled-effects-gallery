// NAME: Flow field
// Flow field - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// five wells of ink, each as wide as its band is loud, carried along a current the mid drives
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
    float ph = texture(iChannel0, vec2(0.5)).a + iTimeDelta * (0.20 + 1.6 * iMid * REACT);
    vec2 v = vec2(sin(p.y * 5.0 + ph) + cos(p.x * 3.0 - ph * 0.7), cos(p.x * 5.0 - ph) + sin(p.y * 3.0 + ph * 0.6));
    vec3 col = texture(iChannel0, uv_of(p - v * (0.004 + 0.012 * iMid * REACT) * K)).rgb * pow(0.978, K);
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        vec2 c = 0.30 * vec2(1.2 * cos(fi * 1.2566 + ph * 0.2), sin(fi * 1.2566 + ph * 0.2));
        float r = 0.040 + 0.110 * SPEC(0.02 + fi / 5.0 * 0.7) * REACT;
        col = max(col, pal(fi / 5.0 + iTime * 0.03) * smoothstep(r, r * 0.4, length(p - c)));
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
