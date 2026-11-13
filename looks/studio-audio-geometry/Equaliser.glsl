// NAME: Equaliser
// Equaliser - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// the spectrum as bars from the middle out, in blocks, mirrored in a floor - the classic, made to be read on LEDs
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
//@ image
//@ iChannel0 = none
//@ iChannel1 = sound
//@ iChannel2 = none
//@ iChannel3 = none
void mainImage(out vec4 o, in vec2 f) {
    vec2 uv = f / iResolution.xy;
    float n = 14.0;
    float x = abs(uv.x * 2.0 - 1.0);                           // mirrored about the middle
    float bar = floor(x * n);
    float inbar = fract(x * n);
    float h = 0.06 + 0.82 * SPEC(0.02 + bar / n * 0.7) * REACT;
    float floor_y = 0.30;
    float y = (uv.y - floor_y) / (1.0 - floor_y);              // 0 at the floor, 1 at the top
    float gap = step(0.14, inbar) * step(inbar, 0.86);
    float blocks = step(0.18, fract(y * 12.0));
    float lit = step(0.0, y) * step(y, h) * gap * blocks;
    float refl = step(y, 0.0) * step(-y * 2.2, h) * gap * 0.28 * (1.0 + y * 2.2);
    float cap = step(0.0, y) * gap * smoothstep(0.035, 0.0, abs(y - h - 0.03));
    vec3 col = pal(0.62 - y * 0.45 + bar / n * 0.25);
    o = vec4(col * (lit + refl) + vec3(1.0) * cap * 0.9, 1.0);
}
