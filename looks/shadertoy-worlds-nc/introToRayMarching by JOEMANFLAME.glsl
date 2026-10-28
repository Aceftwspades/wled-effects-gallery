// introToRayMarching by JOEMANFLAME - https://www.shadertoy.com/view/MXVXWd - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: introToRayMarching (JOEMANFLAME)
// introToRayMarching by JOEMANFLAME
// https://www.shadertoy.com/view/MXVXWd
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// Credit - kishimisu on YouTube for the tutorial and for introducing me into this beautiful, mystifying, entrancing rabbit hole that I may never come out from
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
//--------------------------------------------------------------------------------------------------------------------
// Geometry
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end

// Functions
mat2 rot2D(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

vec3 rot3D(vec3 p, vec3 axis, float angle) {
    // Rodrigues' rotation formula
    return mix(dot(axis, p)*axis, p, cos(angle)) + cross(axis, p) * sin(angle);
    
}

float smin( float a, float b, float k )
{
    k *= 1.0;
    float r = exp2(-a/k) + exp2(-b/k);
    return -k*log2(r);
}

float sUnion (float d1, float d2, float k) {
        float h = clamp(0.5 + 0.5 *(d2-d1)/k, 0.0, 1.0);
        return mix(d2, d1, h) - k*h*(1.0-h);
}

vec3 palette( in float t )
{
    vec3 a = vec3(0.5, 0.5, 0.5); 
    vec3 b = vec3(0.500, 0.500, 0.500);
    vec3 c = vec3(1.000, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.577);
    
    return a + b*cos( 6.28318*(c*t+d) );
}


// Geometry SDFs
float sdSphere(vec3 p, float s) {
    return length(p) - 1.0;             // SDF of a sphere of radius 1
}

float sdBox (vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);  // SDF of a box with xyz = b
}

float sdOctahedron( vec3 p, float s)
{
  p = abs(p);
  return (p.x+p.y+p.z-s)*0.57735027;
}

// Mapping
float map(vec3 p) {
    
    p.z += iTime*.6;
    
    // Space Repetition
    p.xy = fract(p.xy) - 0.5;     // Spacing = 1 ( -0.5 translates vec3 to center of unit square )
    p.z = mod(p.z, 0.25) - 0.125;  // Spacing = 0.25
    
    float box = sdOctahedron(p, 0.15); // SDF of box
    
    // smooth union between the objeccts
    return box;
}

//--------------------------------------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;  // transform px coordinates into uv-space
    vec2 m = ( iMouse.xy * 2.0 - iResolution.xy) / iResolution.y; // px coordinates into uv-space for mouse
    
    // Initialization
    vec3 r0 = vec3(0, 0, -3.0); // ray origin
    vec3 rd = normalize(vec3(uv*0.7, 1));  // ray direction NOTE: leverage use of UV coordinates being the xy axes of screen,
                                       // can plug them into x and y of vec3, meaning each pixel has its own ray-Dir

    vec3 col = vec3(0);                // final pixel color
    
    float t = 0.0;                     // Distance Travelled                                
    int iter = 80;                     // ray-march iterations to perform (per pixel)
    
    //Vertical camera rotation (Goes first)
    //r0.yz *= rot2D(-m.y);
    //rd.yz *= rot2D(-m.y);
    
    //Horizontal camera rotation
    //r0.xz *= rot2D(-m.x);
    //rd.xz *= rot2D(-m.x);
    
    if (iMouse.z < 0.) m = vec2(cos(iTime*0.2), sin(iTime*0.2));
    
    // Raymarching
    int i;
    for (i = 0; i < iter; i++) {
        vec3 p = r0 + rd * t;              // Position along the ray w.r.t. the rays origin
        
        p.xy *= rot2D(t*0.2 * m.x);    // rotate ray based on distance travelled
        
        p.y += sin(t*(m.y+1.0)*0.5)*0.35;  // add sin component w frequency of t (distance travelled)
        
        
        float d = map(p);              // current distance to the scene

        t += d;                        // "march" the ray
        
        // col = vec3(i) / float(iter);   // output color based on number of iterations performed
        
        if ( d < 0.001 || t > 100.0) break;       // stop ray-marching if sufficiently close to geometry or stop ray-marching if ray passes all geometry
    }
    
    
    // Coloring
    col = palette(t*0.05 + float(i)*0.005);            // color based on distance the ray has travelled
    
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
