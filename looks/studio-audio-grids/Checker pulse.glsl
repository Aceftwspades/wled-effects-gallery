// NAME: Checker pulse
// Checker pulse - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// a checkerboard whose squares swell with the sound - one colour of square with the bass, the other with the treble
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
    o = vec4(0.0, 0.0, 0.0, mod(ph + iTimeDelta * (0.15 + 1.2 * iLevel * REACT), 1000.0));
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = sound
//@ iChannel2 = none
//@ iChannel3 = none
void mainImage(out vec4 o, in vec2 f) {
    vec2 p = centred(f) * 5.0;
    float ph = texture(iChannel0, vec2(0.5)).a;
    vec2 cell = floor(p), g = fract(p) - 0.5;
    float odd = mod(cell.x + cell.y, 2.0);
    float far = clamp(length(cell + 0.5) / 4.0, 0.0, 1.0);
    float band = mix(0.03 + 0.20 * far, 0.45 + 0.25 * far, odd);
    float size = 0.10 + 0.40 * SPEC(band) * REACT;
    float lit = smoothstep(size, size - 0.06, max(abs(g.x), abs(g.y)));
    vec3 col = pal(odd * 0.5 + far * 0.3 - ph * 0.15);
    o = vec4(col * lit, 1.0);
}
