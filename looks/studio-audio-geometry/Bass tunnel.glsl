// NAME: Bass tunnel
// Bass tunnel - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// a tunnel flown at the bass's speed, its rings as thick as the spectrum is loud, a lurch on the beat
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
    o = vec4(0.0, 0.0, 0.0, mod(ph + iTimeDelta * (0.25 + 2.6 * iBass * REACT), 1000.0));
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = sound
//@ iChannel2 = none
//@ iChannel3 = none
void mainImage(out vec4 o, in vec2 f) {
    vec2 p = centred(f);
    float ph = texture(iChannel0, vec2(0.5)).a;
    float r = length(p) + 1e-3;
    float depth = 0.28 / r + ph + 0.35 * iBeat * REACT;
    float ang = atan(p.y, p.x) / 6.2832 + 0.02 * sin(depth * 0.7);
    float ring = fract(depth * 1.5);
    float band = fract(floor(depth * 1.5) * 0.137);
    float thick = 0.18 + 0.62 * SPEC(0.03 + band * 0.6) * REACT;
    float lit = smoothstep(thick, thick - 0.12, abs(ring - 0.5) * 2.0);
    float spokes = smoothstep(0.30, 0.20, abs(fract(ang * 8.0 + floor(depth * 1.5) * 0.25) - 0.5));
    vec3 col = pal(band + iTime * 0.03) * lit * (0.35 + 0.65 * spokes);
    o = vec4(col * smoothstep(0.02, 0.22, r), 1.0);
}
