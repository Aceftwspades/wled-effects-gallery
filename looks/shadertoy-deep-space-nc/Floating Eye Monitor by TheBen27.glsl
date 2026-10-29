// Floating Eye Monitor by TheBen27 - https://www.shadertoy.com/view/lfjSRh - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: Floating Eye Monitor (TheBen27)
// Floating Eye Monitor by TheBen27
// https://www.shadertoy.com/view/lfjSRh
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// textures:
//   Buffer A's iChannel0 was a texture on Shadertoy - choose a picture of your own for it beside the deck's channels (noise until then)
// This desktop monitoring software guarantees productivity at an affordable cost. No observable side effects. Designed for workplaces, call centers, computer labs. Limit continuous exposure 3hrs/day.
//@ buffer A
//@ iChannel0 = image
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
float sminCubic( float a, float b, float k ) {
    float h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*h*k*(1.0/6.0);
}

vec2 hash22(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}

mat2 rot(float t) {
    return mat2(cos(t), -sin(t), sin(t), cos(t));
}

vec2 noise(vec2 p) {
    vec2 cc = floor(p);
    vec2 cm = p - cc;
    vec2 tl = hash22(cc);
    vec2 tr = hash22(cc + vec2(1.0, 0.0));
    vec2 bl = hash22(cc + vec2(0.0, 1.0));
    vec2 br = hash22(cc + vec2(1.0, 1.0));
    vec2 t = mix(tl, tr, cm.x);
    vec2 b = mix(bl, br, cm.x);
    return mix(t, b, cm.y);
}

vec2 noise_oct(vec2 p) {
    vec2 value = vec2(0.0);
    float total = 0.0;
    float a = 1.0;
    float f = 1.0;
    for (float i = 0.0; i < 5.0; i++) {
        p *= rot(24.0);
        value += noise(p * f) * a;
        total += a;
        a /= 2.0;
        f *= 2.0;
    }
    return value / total;
}

float fmod(float x, float m) {
    return x - m * floor(x / m);
}

float angleVoronoi(vec2 uv, vec2 scale, float smoothness, int octave, float twisting) {
    float theta = 0.5 + atan(uv.y, uv.x) / (2.0 * acos(-1.0));
    float phi = length(uv);
    float speed = float(1 + octave) * 0.015;
    theta += twisting * (0.25 * phi - speed * iTime);
    vec2 auv = vec2(theta, phi);
    
    vec2 pos = auv * scale;
    vec2 innerPos = mod(pos, 1.0);
    vec2 index = floor(pos);
 
    float minDistance = 1e3;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y));
            vec2 cellPos = offset + hash22(
                vec2(
                    fmod(index.x + offset.x, scale.x),
                    index.y + offset.y
                )
            );
            float cellDistance = distance(innerPos, cellPos);
            minDistance = sminCubic(minDistance, cellDistance, smoothness);
        }
    }
    return minDistance;
}

float dither_by(float value, float dither) {
    return round(dither - 0.5 + value);
}

float vortex(vec2 uv, float dither) {
    // Waviness
    uv.x += 0.04 * sin(iTime + 4.0 * uv.y);
    
    float brightness;
    float total = 0.0;
    float a = 1.0;
    vec2 f = vec2(6.0, 3.0);
    int octaves = 6;
    for (int i = 0; i < octaves; i++) {
        brightness += a * angleVoronoi(uv, f, length(uv) * 0.5, i, 1.0);
        total += a;
        a *= 0.5;
        f *= 2.0;
    }
    
    brightness /= total;
    
    // Cheat by removing the center
    float center = smoothstep(0.0, 0.2, length(uv));
    brightness = mix(0.0, brightness, center);
    
    // Postersize and dither
    brightness *= brightness;
    brightness = max(0.0, brightness - 0.025);
    brightness = dither_by(brightness, dither);
    return brightness;
}

vec2 eye(vec2 uv, float dither) {
    float size = 0.3;
    float thick = 0.03;
    // Float eye up and down
    uv.y -= 0.02 * round(sin(iTime * 0.5) * 5.0) / 5.0;
    float len = length(uv);
    float alpha = 1.0 - smoothstep(size - thick, size + thick, len);
    // Base
    float value = 1.0;
    vec2 idisp = 0.02 * (noise_oct(vec2(iTime)) - 0.5);
    vec2 iuv = uv - idisp;
    float ilen = length(iuv);
    // Iris
    float a = angleVoronoi(iuv, vec2(32.0, 3.0), 0.1, 0, 0.0);
    value *= a;
    // Black pupil
    value *= smoothstep(0.1, 0.15, ilen);
    // Black rim around the iris
    value *= smoothstep(0.0, 0.025, abs(ilen - 0.2));
    // Sclera
    value = max(value, smoothstep(0.19, 0.21, ilen));
    // White highlight
    float cl = distance(uv, vec2(0.03, 0.07));
    value = max(value, step(cl, 0.005));
    
    value = dither_by(value, dither);
    alpha = dither_by(alpha, dither);
    
    return vec2(value, alpha);
}

float rift(vec2 uv, float dither) {
    // Base shape
    float amt = pow(1.0 - abs(uv.y), 1.5);
    // Distortion
    amt *= noise_oct(vec2(1.5 * uv.y + iTime, sign(uv.x))).x;
    // Blink
    float blinkTiming = 2.0 * max(0.0, mod(iTime, 5.0) - 4.5);
    float blinkAmt = 0.5 + 0.5 * cos(blinkTiming * 2.0 * acos(-1.0));
    amt *= blinkAmt * blinkAmt;
    // Sharpen and dither
    float value = smoothstep(amt * 0.4, amt, abs(uv.x));
    return dither_by(value, dither);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    const float targetHeight = 720.0;
    float downscale = max(1.0, floor(iResolution.y / targetHeight));
    
    vec2 uv = floor(fragCoord / downscale) / iResolution.xy * downscale;
    uv -= 0.5;
    uv *= 2.0;
    uv.x *= iResolution.x / iResolution.y;
    
    float dither = texelFetch(iChannel0, ivec2(mod(fragCoord / downscale, 8.0)), 0).r;
    float bg_vortex = vortex(uv, dither);
    vec2 fg_eye = eye(uv, dither);
    float bg_rift = rift(uv, dither);
    
    float final = bg_vortex;
    
    final *= bg_rift;
    final = mix(final, fg_eye.x, (1.0 - bg_rift) * fg_eye.y);
    
    // Output to screen
    fragColor = vec4(vec3(final),1.0);
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    vec2 uv = fragCoord / iResolution.xy;
    float zoomFactor = mix(1.35, 1.0, smoothstep(0.0, 1.0, distance(uv, vec2(0.5))));
    uv -= 0.5;
    uv /= zoomFactor;
    uv += 0.5;
    float c = texture(iChannel0, uv).r;
    
    vec3 blackColor = vec3(0.1, 0.125, 0.1);
    vec3 whiteColor = vec3(0.98, 1.0, 0.9);
    vec3 color = mix(blackColor, whiteColor, max(0.0, c));
    
    fragColor = vec4(color, 1.0);
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
