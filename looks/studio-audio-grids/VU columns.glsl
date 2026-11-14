// NAME: VU columns
// VU columns - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// ten columns of blocks, each band's level - and a cap on each that holds the peak, then falls
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
void mainImage(out vec4 o, in vec2 f) {             // a column's held peak, in every pixel of it
    float n = 10.0;
    float c = floor(f.x / iResolution.x * n);
    float s = clamp(SPEC(0.02 + c / n * 0.7) * REACT * 1.2, 0.0, 1.0);
    float held = texture(iChannel0, vec2((c + 0.5) / n, 0.5)).a;
    o = vec4(0.0, 0.0, 0.0, max(s, held - 0.011 * K));
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = sound
//@ iChannel2 = none
//@ iChannel3 = none
void mainImage(out vec4 o, in vec2 f) {
    vec2 uv = f / iResolution.xy;
    float n = 10.0;
    float c = floor(uv.x * n);
    float s = clamp(SPEC(0.02 + c / n * 0.7) * REACT * 1.2, 0.0, 1.0);
    float peak = texture(iChannel0, vec2((c + 0.5) / n, 0.5)).a;
    float gap = step(0.12, fract(uv.x * n)) * step(fract(uv.x * n), 0.88);
    float rows = 12.0;
    float block = step(0.16, fract(uv.y * rows));
    float row = floor(uv.y * rows) / rows;
    float lit = step(row, s - 0.001) * gap * block;
    float cap = step(abs(row - floor(peak * rows - 0.001) / rows), 0.001) * gap * block;
    vec3 col = mix(vec3(0.10, 1.00, 0.30), vec3(1.00, 0.15, 0.10), smoothstep(0.45, 0.95, row));
    col = mix(col, vec3(1.00, 0.85, 0.10), smoothstep(0.35, 0.60, row) * (1.0 - smoothstep(0.60, 0.85, row)));
    o = vec4(col * lit + vec3(1.0) * cap * (1.0 - lit), 1.0);
}
