// NAME: Wave tunnel
// Wave tunnel - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// the wave as a ring, pulled toward you: harder with the bass, kicked on the beat, turned by the mid
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
    float pull = (0.020 + 0.050 * iBass * REACT + 0.040 * iBeat * REACT) * K;
    float turn = (0.010 + 0.040 * (iMid - 0.25) * REACT) * K;
    vec3 prev = texture(iChannel0, uv_of(rot(turn) * p * (1.0 - pull))).rgb * pow(0.94, K);
    float ang = atan(p.y, p.x) / 6.2832 + 0.5;
    float w = WAVE(abs(ang * 2.0 - 1.0));                      // mirrored, so the ring closes
    float r0 = 0.15 + 0.05 * iBass + 0.11 * w * REACT;
    float line = smoothstep(0.030, 0.0, abs(length(p) - r0));
    vec3 col = pal(iTime * 0.05 + ang + iTreble * 0.3);
    o = vec4(max(prev, col * line), 1.0);
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
void mainImage(out vec4 o, in vec2 f) {
    o = vec4(texture(iChannel0, f / iResolution.xy).rgb, 1.0);
}
