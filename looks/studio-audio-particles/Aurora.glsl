// NAME: Aurora
// Aurora - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// curtains of light as tall as the spectrum is loud, swaying at the mid's pace
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
    o = vec4(0.0, 0.0, 0.0, mod(ph + iTimeDelta * (0.20 + 1.4 * iMid * REACT), 1000.0));
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = sound
//@ iChannel2 = none
//@ iChannel3 = none
void mainImage(out vec4 o, in vec2 f) {
    vec2 uv = f / iResolution.xy;
    float ph = texture(iChannel0, vec2(0.5)).a;
    float x = uv.x + 0.035 * sin(uv.y * 5.0 + ph) ;
    float h = 0.26 + 0.95 * SPEC(0.02 + abs(x * 2.0 - 1.0) * 0.6) * REACT;
    float y = uv.y - 0.04 * sin(x * 9.0 + ph) - 0.03 * sin(x * 23.0 - ph * 1.7);
    float base = 0.10;
    float lit = smoothstep(base, base + 0.06, y) * smoothstep(base + h, base + h * 0.35, y);
    float rays = 0.55 + 0.45 * sin(x * 70.0 + ph * 2.0 + 4.0 * sin(x * 11.0));
    vec3 col = mix(vec3(0.10, 1.00, 0.45), vec3(0.55, 0.20, 1.00), smoothstep(base, base + h, y));
    o = vec4(col * lit * rays, 1.0);
}
