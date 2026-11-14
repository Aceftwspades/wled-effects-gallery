// NAME: Sound rings
// Sound rings - WLED Effects Studio - CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
// a spectrogram in the round: what is playing now is the dot in the middle - red for bass, green for mid, blue for treble - and its past rings out from it
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
    float out_by = (0.0035 + 0.0090 * iLevel * REACT) * K;       // the same speed at every radius: rings, not a blur
    vec3 col = texture(iChannel0, uv_of(p - normalize(p + vec2(1e-5)) * out_by)).rgb * pow(0.990, K);
    vec3 now = vec3(iBass, iMid * 1.3, iTreble * 1.6) * REACT;
    now = now / max(max(now.r, max(now.g, now.b)), 0.25) * clamp(0.25 + iLevel * 1.5, 0.0, 1.0);
    float dot_ = smoothstep(0.060, 0.040, length(p));
    o = vec4(mix(col, now, dot_), 1.0);
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
void mainImage(out vec4 o, in vec2 f) {
    o = vec4(texture(iChannel0, f / iResolution.xy).rgb, 1.0);
}
