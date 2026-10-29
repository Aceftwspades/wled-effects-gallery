// Parametric Trochoid by sanblu - https://www.shadertoy.com/view/lcXyWN - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: Parametric Trochoid (sanblu)
// Parametric Trochoid by sanblu
// https://www.shadertoy.com/view/lcXyWN
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// Main elements of this shader:
// 1) simple trichoid parametric curve (4 rotating circles stacked on top of each other)
// 2) a separate function for controlling the "thickness" of the curve
// 3) the curve SDF is based on piecewise line segments
//@ common
#define FLT_MAX 3.402823466e+38
#define PI 3.14159
#define PI2 6.28318530718
#define UINT_MAX 4294967295.0

// https://www.pcg-random.org/
// http://www.jcgt.org/published/0009/03/02/
uint pcg1d(in uint v)
{
    uint state = v * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

// https://iquilezles.org/articles/palettes
vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b*cos( 6.28318*(c*t+d) );
}

//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
// The MIT License
// Copyright © 2024 Sandro Blum
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end

// Main elements:
// 1) a trichoid parametric curve (4 rotating circles stacked on top of each other)
// 2) a separate function for controlling the "thickness" of the curve
// 3) the curve SDF is based on piecewise line segments (more segments for curved areas, idea by inigo quilez -> https://www.shadertoy.com/view/Xlf3zl)

// note1: the concept of 2) 3) can be used for any parametric curve, doesn't need to be the trichoid curve

// trochoid parametric curve
// for context, see: https://scholarcommons.scu.edu/cgi/viewcontent.cgi?article=1004&context=math_compsci
vec2 trochoid(float t, bvec4 clockwise, vec4 cf, vec4 weights) {
    return 0.5 + 0.5 * (
            weights[0] * (clockwise[0] ? vec2(cos(cf[0] * t),sin(cf[0] * t)) : vec2(sin(cf[0] * t),cos(cf[0] * t))) +
            weights[1] * (clockwise[1] ? vec2(cos(cf[1] * t),sin(cf[1] * t)) : vec2(sin(cf[1] * t),cos(cf[1] * t))) +
            weights[2] * (clockwise[2] ? vec2(cos(cf[2] * t),sin(cf[2] * t)) : vec2(sin(cf[2] * t),cos(cf[2] * t))) +
            weights[3] * (clockwise[3] ? vec2(cos(cf[3] * t),sin(cf[3] * t)) : vec2(sin(cf[3] * t),cos(cf[3] * t)))
        );
}

float curveThickness(float t) {
    return 0.002 + 0.006 * sin(16.0 * t + iTime);
}

float minDistance(vec2 uv, vec2 pos0, vec2 pos1, float thickness0, float thickness1, float minDist) {
        vec2 dir = normalize(pos1 - pos0);
        vec2 nearestPoint = clamp(dot(uv - pos0, dir), 0.0, length(pos1 - pos0)) * dir + pos0;
        float dist = length(uv - nearestPoint);
        float thickness = mix(thickness0, thickness1, clamp(dot(uv - pos0, dir) / length(pos1 - pos0), 0.0, 1.0));
        return min(minDist, dist - thickness); 
}

float curveSd(vec2 uv, bvec4 clockwise, vec4 cf, vec4 weights) {
    float minDist = FLT_MAX;
    float t0 = 0.0;
    float t1 = 0.02;
    while (true) {
        vec2 pos0 = trochoid(t0, clockwise, cf, weights);
        vec2 pos1 = trochoid(t1, clockwise, cf, weights);
        float thickness0 = curveThickness(t0);
        float thickness1 = curveThickness(t1);         
        minDist = minDistance(uv, pos0, pos1, thickness0, thickness1, minDist);
        
        if (t1 == PI2) {
            break;
        }        
        
        // increase segment density for curved areas
        // idea by inigo quilez: https://www.shadertoy.com/view/Xlf3zl
        float delta = clamp(0.0006 * length(pos0 - uv) / length(pos0 - pos1), 0.0002, 0.01 );        
        t0 = t1;        
        t1 = min(t1 + delta, PI2);
    }   
    return minDist;
}


vec4 randomWeights(in uint seed) {
    uint rnd1 = pcg1d(seed);
    uint rnd2 = pcg1d(rnd1);
    uint rnd3 = pcg1d(rnd2);
    uint rnd4 = pcg1d(rnd3);       
    vec4 weights = vec4(rnd1, rnd2, rnd3, rnd4) / UINT_MAX;
    weights /= weights.x + weights.y + weights.z + weights.w;
    return weights;
}


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    float aspectRatio = iResolution.x/iResolution.y;
    uv.x = uv.x * aspectRatio - (aspectRatio - 1.0) * 0.5;

    // for this demo we choose just one specific trichoid configuration (there are tons of other configurations that look nice too)    
    int n = 4;
    bvec4 clockwise = bvec4(1, 1, 0, 1);
    vec4 cf = vec4(1, 7, 17, 13);
    
    float mixRatio = smoothstep(0.3, 0.7, cos(iTime * 1.0) * 0.5 + 0.5);    
    uint rootSeed = 1339u;
    uint seedA = rootSeed + uint(0.5 * iTime / PI);
    uint seedB = rootSeed * 7u + uint((0.5 * iTime + PI * 0.5) / PI);    
    vec4 weightsA = randomWeights(seedA);
    vec4 weightsB = randomWeights(seedB);
    vec4 weights = mix(weightsA, weightsB, mixRatio);

    float dist = curveSd(uv, clockwise, cf, weights);    
    
    float val = 1.0 - pow(clamp(dist,0.0,1.0),0.5);    
    vec3 col = pal(val, vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(1.0,1.0,0.5), vec3(0.8,0.9,0.3));
    fragColor = vec4(col, 1.0);                
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
