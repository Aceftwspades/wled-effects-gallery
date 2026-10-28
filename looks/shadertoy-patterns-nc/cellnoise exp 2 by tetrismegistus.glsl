// cellnoise exp 2 by tetrismegistus - https://www.shadertoy.com/view/Mfsczn - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: cellnoise exp 2 (tetrismegistus)
// cellnoise exp 2 by tetrismegistus
// https://www.shadertoy.com/view/Mfsczn
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// experimenting with presentations of cellular noise, most code here comes directly from the book of shaders
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
vec2 random2( vec2 p ) { 
 return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

float sdHexagon( in vec2 p, in float r )
{
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    return length(p)*sign(p.y);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 st = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float hexagon = sdHexagon(st, .5);
       
    // Scale
    st *= 50.;

    // Tile the space
    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float m_dist = 1.;  // minimum distance

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            // Neighbor place in the grid
            vec2 neighbor = vec2(float(x),float(y));

            // Random position from current + neighbor place in the grid
            vec2 point = random2(i_st + neighbor);

			// Animate the point
            point = 0.5 + 0.5*sin(iTime + 6.2831*point);

			// Vector between the pixel and the point
            vec2 diff = neighbor + point - f_st;

            // Distance to the point
            float dist = length(diff);

            // Keep the closer distance
            m_dist = min(m_dist, dist);
        }
    }

    vec3 blue = vec3(0.455,0.537,0.753);
    vec3 orange = vec3(0.961,0.318,0.035);
    vec3 offWhite = vec3(0.941,0.918,0.776);
    
    vec3 verGrad = mix(orange, blue, st.y);
    vec3 horGrad = mix(offWhite, blue, st.x);
    vec3 mixGrad = mix(verGrad, horGrad, sin(iTime));    
  
    
    vec3 color = mixGrad - m_dist;
    
 
    fragColor = vec4(color * hexagon,1.0);
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
