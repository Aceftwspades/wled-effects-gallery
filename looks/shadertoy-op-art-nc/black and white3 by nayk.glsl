// black and white3 by nayk - https://www.shadertoy.com/view/McscDH - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: black and white3 (nayk)
// black and white3 by nayk
// https://www.shadertoy.com/view/McscDH
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// originals  https://www.shadertoy.com/view/XcfyWH
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end

float intensity = 1.0;
float radius2 = 0.05;
float happy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
 
//Distance functions from
//https://iquilezles.org/articles/distfunctions2d
float triangleDist(vec2 p){
    const float k = sqrt(3.0);
    p.x = abs(p.x) - 1.0;
    p.y = p.y + 1.0/k;
    if( p.x+k*p.y>0.0 ) p=vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0, 0.0 );
    return -length(p)*sign(p.y);
}

float boxDist(vec2 p){
    vec2 d = abs(p)-1.0;
    return length(max(d,vec2(0))) + min(max(d.x,d.y),0.0);
}

float circleDist( vec2 p){
  return length(p) - 1.0;
}

//https://www.shadertoy.com/view/3s3GDn
float getGlow(float dist, float radius, float intensity){
    return pow(radius/dist, intensity);
}
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

   
   
   
    vec2 uv2  =fragCoord/iResolution.xy-0.5;
uv*=2.5;

    float widthHeightRatio = iResolution.x/iResolution.y;
    vec2 centre;
    vec2 pos;

    float t = -iTime * 0.05;
   
    float dist;
    float glow;
    vec3 col = vec3(0);
   
    //The spacing between shapes
    const float scale = 150.0;
    //Number of shapes
    const float layers = 10.0;
   
    float depth;
    vec2 bend;
   
    const vec3 purple = vec3(0.611, 0.129, 0.909);
    const vec3 green = vec3(0.133, 0.62, 0.698);
   
    float angle;
    float rotationAngle;
    mat2 rotation;
   
    //For movement of the anchor point in time
    float d = 2.5*(sin(t) + sin(3.0*t));

    //Create an out of frame anchor point where all shapes converge to    
    //vec2 anchor = vec2(0.5 + cos(d), 0.5 + sin(d));
    vec2 anchor = vec2(0.5);

    //Create light purple glow at the anchor loaction
    pos = anchor - uv;
  
    dist = length(pos);
    glow = getGlow(dist, 0.35, 0.9);

   
for(float i = 0.0; i < layers; i++){
       
       
        depth = fract(i/layers + t);

        //Move the focus of the camera in a circle
        //centre = vec2(0.5 + 0.2 * sin(t), 0.5 + 0.2 * cos(t));
        centre = vec2(0.0);
        //Position shapes between the anchor and the camera focus based on depth
        bend = mix(anchor, centre, depth);
     
        pos =  uv;


        //Rotate shapes
        rotationAngle = 3.14 * sin(depth + fract(t) * 6.28) + i;
        rotation = mat2(cos(rotationAngle), -sin(rotationAngle),
                        sin(rotationAngle),  cos(rotationAngle));
       
        pos *= rotation;
       
        //Position shapes according to depth
    pos *= mix(scale, 0.0, depth);
   
        float m = mod(i, 3.0);
        if(m == 0.0){
        dist = abs(boxDist(pos));
        }else if(m == 1.0){
        dist = abs(triangleDist(pos));
        }else{
        dist = abs(circleDist(pos));
        }
       
        //Get glow from base radius and intensity modified by depth
    glow = getGlow(dist, radius2+(1.0-depth)*2.0, intensity + depth);
       
        //Find angle along shape and map from [-PI; PI] to [0; 1]
        angle = (atan(pos.y, pos.x)+3.14)/6.28;
        //Shift angle depending on layer and map to [1...0...1]
angle = abs((2.0*fract(angle + i/layers)) - 1.0);
       
        //White core
    col += 10.0*vec3(smoothstep(0.03, 0.02, dist));
       
        //Glow according to angle value
      col += glow * mix(green, purple, angle);
}
   
  
   
    float radius = 0.8;
    float smoothEdge = 0.01;

    float dist2 = length(uv);
 float time = iTime;

    float angle3 = atan(uv.y, uv.x);
    float radius3 = length(uv);
    angle3 = mod(angle3, 3.14159265 / 3.0) * 6.0;
    uv = vec2(cos(angle3), sin(angle3)) * radius3;

    vec3 color = vec3(0.0);

    float r1 = 0.5;
    float r2 = 0.2;

    float scale3 = 1.;

    for (int i = 0; i < 95; i++) {
    
        uv2 += vec2(sin(time), cos(time)) * 0.05; 
        
        uv2 = fract(uv * scale3) - 0.5;
        float len = length(uv2);
        float angle3 = atan(uv2.y, uv2.x);

        float d = abs(r1 - len) - r2;

        vec3 kColor = vec3(.7, .7, .1) * (0.5 + 0.5 * cos(6.0 * angle3 + time));
        color += kColor / (d * scale + 0.0);
        
        scale3 *= 1.3;
    }

    color = pow(color, vec3(0.4545));
    float angle2 = iTime * 0.523598776;
float t2 = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv.xy) + .07)) * 1.2;
	float si = sin(t2);
	float co = cos(t2);
	mat2 ma = mat2(co, si, -si, co);
    
    vec2 rotatedUV = uv;
    rotatedUV.x+=cos(iTime);
         rotatedUV.y+=sin(iTime);
    if (dist2 < radius)
    {
        float s = sin(angle2);
        float c = cos(angle2);
        rotatedUV = vec2(c * uv.x - s * uv.y, s * uv.x + c * uv.y)*ma;
         
    }

    vec2 checker = floor(uv * 10.0);
  
    vec2 rotatedChecker = floor(rotatedUV *col.xy* 10.0);
    float checkerPattern = mod(rotatedChecker.x + rotatedChecker.y, 2.0);
 
    float circleEdge = smoothstep(radius - smoothEdge, radius + smoothEdge, dist);

    float pattern = mix(checkerPattern, checkerPattern, circleEdge);

    vec3 color2 = vec3(pattern);

    fragColor = vec4(color*color2, 1.0);
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
