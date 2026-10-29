// Voronoi Edges Artwork #1 Y28 by Yusef28 - https://www.shadertoy.com/view/lXVXWt - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: Voronoi Edges Artwork #1 Y28 (Yusef28)
// Voronoi Edges Artwork #1 Y28 by Yusef28
// https://www.shadertoy.com/view/lXVXWt
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// textures:
//   Image's iChannel1 was a texture on Shadertoy - choose a picture of your own for it beside the deck's channels (noise until then)
// From my tutorial on the voronoi and voronoi edges algorithms:
// Part 1: https://youtu.be/g2bILAVIIvM?si=mfm4dA_U59PA6B_8
// Part 2: https://youtu.be/oIbj64Cq8HA?si=2W3m0xPmPKnByCws
//@ image
//@ iChannel0 = cube
//@ iChannel1 = image
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
/* 
This Voronoi Shader is based on:

1. An article by IQ: 
    https://iquilezles.org/articles/voronoilines
2. tomkh's drawing helped it click: 
    https://www.shadertoy.com/view/llG3zy
3.Shane's Rounded border shader inspired the lighting/art style:
    https://www.shadertoy.com/view/ll3GRM
*/


#define pi 3.141592
#define eps 20./iResolution.y

vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);

}

//smoothMin funciton
float smin2(float a, float b, float r)
{
   float f = max(0., 1. - abs(b - a)/r);
   return min(a, b) - r*.25*f*f;
}

//voronoi edges function
vec4 voronoiEdges(vec2 uv){
    
    vec2 currentCell = floor(uv);
    float minDist = 8.0;
    vec2 A;

    for(float i = -1.; i <= 1.; i++){
        for(float j = -1.; j <= 1.; j++){
            vec2 neighbor = vec2(i,j);
            vec2 offset = hash22(currentCell + neighbor);
            offset = 0.3+0.3*sin(3.141592*2.*offset+iTime);
            vec2 position = (currentCell + neighbor + offset);
            float dist = length(uv - position);

            if(dist < minDist){
                minDist = dist;
                A = position;
            }
        }
    }

    
    float secondMinDist = 8.;
    for(float i = -1.; i <= 1.; i++){
        for(float j = -1.; j <= 1.; j++){
            vec2 neighbor = vec2(i,j);
            vec2 offset = hash22(currentCell + neighbor);
            offset = 0.3+0.3*sin(3.141592*2.*offset+iTime);
            vec2 position = (currentCell + neighbor + offset);
            vec2 B = position;

            if( dot(A-B,A-B)<0.001 )continue;
            vec2 halfWay = uv-0.5*(A+B);
            vec2 dir = normalize(A-B);
            float distToEdge = dot(halfWay, dir);
            secondMinDist = smin2(secondMinDist,  distToEdge, 0.2); 
        }
    }
    
    float border = sin(3.14159*1.9+abs(secondMinDist-0.04));
    return vec4(border,secondMinDist, uv-A);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord*2.-iResolution.xy)/iResolution.y;
    
    vec3 rd = normalize(vec3(uv,-1.));

    uv*=2.;
    
    vec4 data = voronoiEdges(uv);
    
    //light 1 position 
    vec3 light = vec3(1.,1.,4.);
    //light 1 direction vector using uv and voronoi height for surface point
    vec3 ldir = normalize(light-vec3(uv.x,data.x,uv.y));
    
    //light2
    vec3 light2 = vec3(1.,2.,4.);
    vec3 ldir2 = normalize(light2-vec3(uv.x,data.x,uv.y));

    vec3 col = 0.5+0.5*sin(vec3(0., 2.,2.99)/1.5+ data.x*pi*5.-0.2);
    
    //grabbing the texture based on the uv-cell point vectors 
    col = mix(col,texture(iChannel1,data.zw).rgb,data.y);
    col *= 0.8;

    
    vec2 e = vec2(20./iResolution.y,0.);
    vec3 n = vec3(
                  voronoiEdges(uv+e).x-voronoiEdges(uv-e).x,
                  voronoiEdges(uv+e.yx).x-voronoiEdges(uv-e.yx).x,
                  e
                  );
    n = normalize(n);

    //phong lighting diffuse and specular for light 1
    float diff = max(dot(ldir,n),0.);
    float spec = pow(max(dot(reflect(-ldir,n),rd),0.),10.);
    col += diff*0.3+vec3(0.8,0.5,0.3)*spec*0.8;
    
    //and for light 2
    float diff2 = max(dot(ldir,n),0.);
    float spec2 = pow(max(dot( reflect(-ldir2,n),rd),0.),10.);
    col += diff2*0.3+vec3(0.1,0.5,0.9)*spec2*0.8;
    

    col = mix(col,pow(col.r*1.4,3.2)*vec3(0.14,0.09,0.05),smoothstep(0.085,0.05,data.y));
    //col = mix(col,pow((diff+diff2+spec+spec2)*2.,1.5)*vec3(0.14,0.09,0.05),smoothstep(0.085,0.05,data.y));
    
    
    float borderMask = smoothstep(0.07,0.06,data.y);
    vec3 env = texture(iChannel0, reflect(n,rd)).rgb;
    col += mix(env*0.3,env,borderMask)*0.3;
    
    col /= 1.5;
    col= pow(col, vec3(1.6));
    
    fragColor = vec4(col,1.0);
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
