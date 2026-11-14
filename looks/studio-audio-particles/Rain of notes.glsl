// NAME: Rain of notes
// Rain of notes - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// streaks falling, a column for each band of the spectrum - as long as the band is loud, falling at the music's pace
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
    o = vec4(0.0, 0.0, 0.0, mod(ph + iTimeDelta * (0.20 + 1.6 * iLevel * REACT), 1000.0));
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = sound
//@ iChannel2 = none
//@ iChannel3 = none
float hash(float n) { return fract(sin(n * 91.345) * 47453.5453); }
void mainImage(out vec4 o, in vec2 f) {
    vec2 uv = f / iResolution.xy;
    float ph = texture(iChannel0, vec2(0.5)).a;
    float cols = 22.0;
    float c = floor(uv.x * cols);
    float len = 0.12 + 0.70 * SPEC(0.02 + c / cols * 0.7) * REACT;
    float y = fract(uv.y + ph * (0.45 + 0.8 * hash(c)) + hash(c + 3.0));     // 0 at the streak's head, rising behind it
    float lit = smoothstep(len, 0.0, y) * step(0.18, fract(uv.x * cols));
    float head = smoothstep(0.05, 0.0, y);
    vec3 col = pal(0.55 + c / cols * 0.5 + iTime * 0.02);
    o = vec4(col * lit + vec3(1.0) * head * 0.6 * step(0.18, fract(uv.x * cols)), 1.0);
}
