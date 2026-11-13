// NAME: Lissajous scope
// Lissajous scope - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// the wave against itself a quarter on - an X-Y scope's figure, as big as the music is loud, turning at the mid's pace
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
    o = vec4(0.0, 0.0, 0.0, mod(ph + iTimeDelta * (0.10 + 1.2 * iMid * REACT), 1000.0));
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = sound
//@ iChannel2 = none
//@ iChannel3 = none
float seg(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    return length(pa - ba * clamp(dot(pa, ba) / max(dot(ba, ba), 1e-6), 0.0, 1.0));
}
// (in silence the wave is flat: a slow figure of its own then, so the deck is not dark)
vec2 pt(float t, float size) {
    float idle = 1.0 - clamp(iLevel * 8.0, 0.0, 1.0);
    return size * vec2(WAVE(t), WAVE(fract(t + 0.25)))
         + idle * 0.22 * vec2(sin(t * 6.2832 * 3.0 + iTime * 0.4), sin(t * 6.2832 * 2.0));
}
void mainImage(out vec4 o, in vec2 f) {
    float ph = texture(iChannel0, vec2(0.5)).a;
    vec2 p = rot(ph * 0.3) * centred(f);
    float size = (0.22 + 0.55 * iLevel) * REACT;
    float d = 1.0;
    vec2 a = pt(0.0, size);
    for (int i = 1; i <= 40; i++) {
        vec2 b = pt(float(i) / 40.0, size);
        d = min(d, seg(p, a, b));
        a = b;
    }
    vec3 col = pal(length(p) * 0.8 + iTime * 0.05 + iTreble * 0.2);
    o = vec4(col * (smoothstep(0.030, 0.006, d) + 0.25 * smoothstep(0.10, 0.0, d)), 1.0);
}
