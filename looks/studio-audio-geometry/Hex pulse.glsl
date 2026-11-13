// NAME: Hex pulse
// Hex pulse - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// a floor of hexagons, each as big as its band is loud - the bass in the middle, the treble at the edge - colour rolling outward at the music's pace
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
    o = vec4(0.0, 0.0, 0.0, mod(ph + iTimeDelta * (0.15 + 1.6 * iLevel * REACT), 1000.0));
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = sound
//@ iChannel2 = none
//@ iChannel3 = none
float hexd(vec2 p) { p = abs(p); return max(dot(p, vec2(0.5, 0.866)), p.x); }
vec4 hexcell(vec2 p) {                                           // xy: place in the cell, zw: the cell's centre
    vec2 r = vec2(1.0, 1.732), h = r * 0.5;
    vec2 a = mod(p, r) - h, b = mod(p - h, r) - h;
    vec2 g = dot(a, a) < dot(b, b) ? a : b;
    return vec4(g, p - g);
}
void mainImage(out vec4 o, in vec2 f) {
    vec2 p = centred(f) * 7.0;
    float ph = texture(iChannel0, vec2(0.5)).a;
    vec4 hc = hexcell(p);
    float far = length(hc.zw) / 5.0;                           // 0 in the middle, ~1 at the edge
    float size = 0.14 + 0.36 * SPEC(0.02 + far * 0.7) * REACT + 0.05 * iBeat * REACT * (1.0 - far);
    float lit = smoothstep(size, size - 0.07, hexd(hc.xy));
    vec3 col = pal(far * 0.7 - ph * 0.25);
    o = vec4(col * lit, 1.0);
}
