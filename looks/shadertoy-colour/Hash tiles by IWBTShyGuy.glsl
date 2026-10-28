// Hash tiles by IWBTShyGuy - https://www.shadertoy.com/view/7tKfzh - CC BY 4.0
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: Hash tiles (IWBTShyGuy)
// https://www.shadertoy.com/view/7tKfzh by IWBTShyGuy - CC BY 4.0
// Copyright © 2022 IWBTShyGuy
// Attribution 4.0 International (CC BY 4.0)
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end

// Hash without Sine https://www.shadertoy.com/view/4djSRW
float hash12(vec2 p) {
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float noise12(vec2 p) {
    vec2 t = fract(p);
    p = floor(p) + vec2(1.365, -0.593);
    vec2 e = vec2(0, 1);
    return mix(
        mix(hash12(p + e.xx), hash12(p + e.yx), t.x),
        mix(hash12(p + e.yx), hash12(p + e.yy), t.x),
        t.y
    );
}

void mainImage(out vec4 O, in vec2 U) {
    O = vec4(0.95, 0.95, 0.9, 1);
    vec2 r = iResolution.xy, m = vec2(0), M = r, p = m, k, l, e = vec2(0, 1);
    float a;
    for (int i = 0; i < int(log2(length(r))/1.2); i++) {
        a = noise12(p + iTime * 0.1);
        if (a > 0.1 * dot(r, e) / dot(r, e.yx)) e = 1.0 - e;
        a = 0.35 + 0.3 * hash12(p + r * sign(U - p));
        p += (m * (1.0 - a) + M * a - p) * e;
        if (abs(dot(p - U, e)) < 2.0) {
            O.xyz *= 0.0;
            return;
        }
        k = clamp(sign(U - p), 0.0, 1.0);
        l = clamp(sign(p - U), 0.0, 1.0);
        m += (max(k * p, m) - m) * e;
        M += (min(k * r + l * p, M) - M) * e;
    }
    a = noise12(p + sign(U - p) * r + iTime * 0.25);
    if (0.3 <= a && a < 0.4) O = vec4(0.9, 0, 0.2, 1);
    else if (0.4 <= a && a < 0.5) O = vec4(0.9, 0.9, 0, 1);
    else if (0.5 <= a && a < 0.6) O = vec4(0, 0.2, 1, 1);
}

#undef mainImage
// --- WLED Effects Studio: made to move with the music (not in the original) ----------------------------------
// the beat swells the picture from its middle and the bass lifts its light, as far as the deck's amount knob says
// (at amount 0 it is the shader as it was)
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 vj_c = 0.5 * iResolution.xy;
    float vj_swell = 1.0 + 0.10 * iAmount * iBeat;
    vj_inner(fragColor, vj_c + (fragCoord - vj_c) / vj_swell);
    fragColor.rgb *= 1.0 + iAmount * (0.5 * iBass - 0.2);
}
