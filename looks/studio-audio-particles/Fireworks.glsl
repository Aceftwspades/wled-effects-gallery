// NAME: Fireworks
// Fireworks - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// five bursts going off in turn at the music's pace, each as wide as its band of the spectrum is loud
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
    o = vec4(0.0, 0.0, 0.0, mod(ph + iTimeDelta * (0.25 + 1.5 * iLevel * REACT), 1000.0));
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = sound
//@ iChannel2 = none
//@ iChannel3 = none
float hash(float n) { return fract(sin(n * 91.345) * 47453.5453); }
void mainImage(out vec4 o, in vec2 f) {
    vec2 p = centred(f);
    float ph = texture(iChannel0, vec2(0.5)).a;
    vec3 col = vec3(0.0);
    for (int b = 0; b < 5; b++) {
        float fb = float(b);
        float clockb = ph * 0.45 + hash(fb) ;
        float t = fract(clockb), n = floor(clockb);
        vec2 c = vec2(hash(fb + n * 7.0) - 0.5, hash(fb * 3.0 + n * 5.0) - 0.4) * vec2(1.1, 0.55);
        float reach = sqrt(t) * (0.16 + 0.42 * SPEC(0.02 + fb / 5.0 * 0.7) * REACT);
        vec3 tint = pal(hash(fb + n) + 0.1 * fb);
        for (int k = 0; k < 10; k++) {
            float a = float(k) * 0.6283 + hash(fb + n * 3.0) * 6.2832;
            vec2 q = c + reach * vec2(cos(a), sin(a)) - vec2(0.0, 0.10 * t * t);
            float dq = length(p - q);
            col += tint * (1.0 - t * t) * (smoothstep(0.045, 0.010, dq) + 0.35 * smoothstep(0.11, 0.0, dq));
        }
    }
    o = vec4(col, 1.0);
}
