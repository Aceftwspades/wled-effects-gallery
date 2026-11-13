// NAME: Kaleido scope
// Kaleido scope - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// the wave folded six ways and fed back: the mid turns the mirror, the bass pulls it in
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
    float ph = texture(iChannel0, vec2(0.5)).a + iTimeDelta * (0.10 + 1.4 * iMid * REACT);
    float r = length(p), a = atan(p.y, p.x) + ph * 0.25;
    float seg = 6.2832 / 6.0;
    a = abs(mod(a, seg) - seg * 0.5);                          // folded into one sixth, mirrored
    vec2 q = r * vec2(cos(a), sin(a));
    vec2 back = rot(0.02 * K) * p * (1.0 - (0.010 + 0.045 * iBass * REACT) * K);
    vec3 prev = texture(iChannel0, uv_of(back)).rgb * pow(0.93, K);
    float x = clamp(q.x / 0.6, 0.0, 1.0);
    float y = 0.07 + 0.16 * WAVE(x) * REACT * (0.4 + iLevel);
    float line = smoothstep(0.030, 0.0, abs(q.y - y)) * step(q.x, 0.6);
    vec3 col = pal(x * 0.5 + iTime * 0.05 + iTreble * 0.2);
    o = vec4(max(prev, col * line), mod(ph, 1000.0));
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
void mainImage(out vec4 o, in vec2 f) {
    o = vec4(texture(iChannel0, f / iResolution.xy).rgb, 1.0);
}
