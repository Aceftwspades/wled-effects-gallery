// NAME: Plasma pulse
// Plasma pulse - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// plasma whose folds tighten with the bass and flow at the music's pace, its colours pushed by the treble
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
    o = vec4(0.0, 0.0, 0.0, mod(ph + iTimeDelta * (0.20 + 2.2 * iLevel * REACT), 1000.0));
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = sound
//@ iChannel2 = none
//@ iChannel3 = none
void mainImage(out vec4 o, in vec2 f) {
    vec2 p = centred(f);
    float ph = texture(iChannel0, vec2(0.5)).a;
    float s = 3.0 + 5.0 * iBass * REACT;
    float v = sin(p.x * s + ph) + sin(p.y * s * 1.3 - ph * 0.7) + sin((p.x + p.y) * s * 0.7 + ph * 1.3)
            + sin(length(p) * s * 2.0 - ph * 2.0 - 3.0 * iBeat * REACT);
    vec3 col = pal(v * 0.22 + iTreble * 0.35 + iTime * 0.02);
    o = vec4(col * (0.35 + 0.65 * smoothstep(-1.5, 1.5, v)), 1.0);
}
