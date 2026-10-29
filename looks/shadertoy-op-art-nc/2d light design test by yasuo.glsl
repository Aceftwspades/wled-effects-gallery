// 2d light design test by yasuo - https://www.shadertoy.com/view/XclyWN - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: 2d light design test (yasuo)
// 2d light design test by yasuo
// https://www.shadertoy.com/view/XclyWN
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// 2d light design test. inspired by Chris Kuroda Light design
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
#define Rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define antialiasing(n) n/min(iResolution.y,iResolution.x)
#define S(d,b) smoothstep(antialiasing(1.5),-antialiasing(1.5),d - b)
#define B(p,s) max(abs(p).x-s.x,abs(p).y-s.y)
#define deg45 .707
#define R45(p) (( p + vec2(p.y,-p.x) ) *deg45)
#define Tri(p,s) max(R45(p).x,max(R45(p).y,B(p,s)))
#define COLORMODE 0

float random (vec2 p) {
    return fract(sin(dot(p.xy, vec2(12.9898,78.233)))* 43758.5453123);
}

// noise and fbm function from https://www.shadertoy.com/view/Xd3GD4
//-----------------------------------------------------------------------------
vec2 hash( vec2 p ){
    p = vec2( dot(p,vec2(127.1,311.7)),
             dot(p,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise2d( in vec2 p ){
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
    
    vec2 i = floor( p + (p.x+p.y)*K1 );
    
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0*K2;
    
    vec3 h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
    
    vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    
    return dot( n, vec3(70.0) );
}

float fbm(vec2 uv){
    float f;
    mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );
    f  = 0.5000*noise2d( uv ); uv = m*uv;
    f += 0.2500*noise2d( uv ); uv = m*uv;
    f += 0.1250*noise2d( uv ); uv = m*uv;
    f += 0.0625*noise2d( uv ); uv = m*uv;
    f = 0.5 + 0.5*f;
    return f;
}

vec2 polarToCartesian(float radius, float angle) {
    return vec2(radius * cos(angle), radius * sin(angle));
}

vec4 light2D(vec2 p, vec2 lightPos, vec3 lightCol, float intensity, float range, float deg, float angle, float noiseAngle){
    float lightRadius = radians(range); // spot light range 
    float aspect = iResolution.x / iResolution.y;
    lightRadius /= aspect;

    vec2 spotLightDir = polarToCartesian(1.,radians(deg)); // rotate light
    float spotAngle =  radians(angle);
    vec2 lightDir = p - lightPos;
    float lightDistance = length(lightDir);
    
    float d = step(dot(normalize(lightDir), normalize(spotLightDir)),cos(spotAngle/2.));
    d = max((length(lightDir)-(lightRadius)),d);
    float d2 = length(lightDir)-0.005;
    d = min(d,d2);
    p*=Rot(radians(noiseAngle));
    p.y+=iTime*0.1;
    float n = fbm(p*3.)*0.6;
    return vec4(intensity * (1. - length(lightDir / lightRadius)) * lightCol+n,d);
}

vec3 torus(vec2 p, vec3 col, float dir, float deg, float size){
    vec2 prevP = p;
    p.x*=dir;
    p*=Rot(radians(iTime*deg+30.));
    float d = abs(length(p)-size)-0.05;
    
    #if COLORMODE
    vec3 cColor = vec3(0.1,0.6,0.8);
    #else
    vec3 cColor = vec3(1.);
    #endif
    
    col = mix(col,cColor*0.2,S(d,0.0));
    
    d = abs(length(p)-size)-0.05;
    d = max(-p.x,d);
    float a = clamp(atan(p.x,p.y)*0.5,0.3,1.);
    col = mix(col,vec3(a)*cColor*0.3,S(d,0.0));
    
    return col;
}

vec3 dots(vec2 p, vec3 col){
    p = mod(p,0.05)-0.025;
    float d = length(p)-0.001;
    return mix(col,vec3(1.),S(d,0.0));
}

float bgEffectItem(vec2 p){
    float size = 0.5;
    
    p.x*=2.;
    p.y-=size*0.5;
    p.y-=0.3;
    p.y-=iTime*0.5;
    
    p.y = mod(p.y,0.6)-0.3;
    float d = abs(Tri(p,vec2(size)))-0.02;
    p.x*=0.5;
    float d2 = length(p-vec2(0.0,-0.2))-0.03;
    return min(d,d2);
}

vec3 bgEffect(vec2 p, vec3 col){
    vec2 prevP = p;
    p+=0.025;
    p*=20.;
    
    vec2 id = floor(p);
    vec2 gd = fract(p)-0.5;
    float n = random(id);
    
    if(n<0.1){
        gd*=Rot(radians(90.));
    } else if(n>=0.1 && n<0.2){ 
        gd*=Rot(radians(180.));
    } else if(n>=0.3 && n<0.4){ 
        gd*=Rot(radians(270.));
    }
    float d = bgEffectItem(gd);
    if(n>=0.5){
        d = 10.0;
    }

    col = mix(col,vec3(0.5),S(d,0.0));
    return col;
}

vec3 bg(vec2 p, vec3 col){
    vec2 prevP = p;
    
    col = dots(p,col);
    
    p*=5.;
    vec2 id = floor(p);
    vec2 gd = fract(p)-0.5;
    float n = random(id);
    
    col = torus(gd,col,(n<0.5)?1.:-1.,30.+n*30.0,0.2+n*0.1);
    return col;
}

vec3 baseLights(vec2 p, vec3 col){
    p.y = abs(p.y);
    float intensity = 0.6;
    #if COLORMODE
    vec3 lightColor = vec3(0.3,0.9,0.8);
    #else
    vec3 lightColor = vec3(1.);
    #endif
    vec4 d = light2D(p,vec2(-0.1,0.1),lightColor,intensity,15.,220.+sin(-iTime*1.5)*5.,10.,10.);
    col = mix(col,d.rgb,S(d.w,0.));
    d = light2D(p,vec2(0.1,0.1),lightColor,intensity,15.,320.+sin(iTime*1.5)*5.,10.,10.);
    col = mix(col,d.rgb,S(d.w,0.));
    
    d = light2D(p,vec2(0.09,0.1),lightColor,intensity,10.,180.+sin(-iTime*2.)*5.,10.,-90.);
    col = mix(col,d.rgb,S(d.w,0.));
    d = light2D(p,vec2(-0.09,0.1),lightColor,intensity,10.,0.+sin(-iTime*2.)*5.,10.,90.);
    col = mix(col,d.rgb,S(d.w,0.));
    
    d = light2D(p,vec2(-0.1,0.1),lightColor,intensity,15.,320.+sin(-iTime*2.)*5.,10.,10.);
    col = mix(col,d.rgb,S(d.w,0.));
    d = light2D(p,vec2(0.1,0.1),lightColor,intensity,15.,220.+sin(-iTime*2.)*5.,10.,10.);
    col = mix(col,d.rgb,S(d.w,0.));
    
    return col;
}

vec3 lightsSystemBack(vec2 p, vec3 col){
    p.x = abs(p.x);
    vec2 prevP = p;
    vec3 d = vec3(0.);
    for(float i = 0.; i<5.; i++){
        p*=Rot(radians(i*65.0+sin(i)*5.*-iTime));
        p = abs(p)-0.18;
        p.y+=0.05;
        d = baseLights(p,col);
    }
    
    return d;
}

vec3 lightsSystemMain(vec2 p, vec3 col){
    p.y = abs(p.y);
    p.y*=-1.;
    float intensity = 0.5;
    vec4 d = light2D(p,vec2(-0.09,-0.2),vec3(1.0),intensity,50.,-80.+sin(-iTime)*5.,20.,10.);
    col = mix(col,d.rgb,S(d.w,0.));
    d = light2D(p,vec2(0.09,-0.2),vec3(1.0),intensity,50.,-100.+sin(iTime)*5.,20.,-10.);
    col = mix(col,d.rgb,S(d.w,0.));
    
    d = light2D(p,vec2(-0.18,-0.23),vec3(1.0),intensity,50.,-80.+sin(-iTime*1.1)*5.,10.,-10.);
    col = mix(col,d.rgb,S(d.w,0.));
    d = light2D(p,vec2(0.18,-0.23),vec3(1.0),intensity,50.,-100.+sin(iTime*1.1)*5.,10.,10.);
    col = mix(col,d.rgb,S(d.w,0.));
    
    d = light2D(p,vec2(-0.25,-0.27),vec3(1.0),intensity,50.,-110.+sin(-iTime*1.2)*5.,20.,-10.);
    col = mix(col,d.rgb,S(d.w,0.));
    d = light2D(p,vec2(0.25,-0.27),vec3(1.0),intensity,50.,-70.+sin(iTime*1.2)*5.,20.,10.);
    col = mix(col,d.rgb,S(d.w,0.));
    
    d = light2D(p,vec2(-0.15,-0.1),vec3(1.0),intensity,120.,-30.+sin(-iTime*1.3)*5.,20.,-60.);
    col = mix(col,d.rgb,S(d.w,0.));
    d = light2D(p,vec2(0.15,-0.1),vec3(1.0),intensity,120.,-150.+sin(iTime*1.3)*5.,20.,60.);
    col = mix(col,d.rgb,S(d.w,0.));    
    
    d = light2D(p,vec2(-0.3,-0.1),vec3(1.0),intensity,90.,-130.+sin(-iTime*1.4)*5.,20.,50.);
    col = mix(col,d.rgb,S(d.w,0.));
    d = light2D(p,vec2(0.3,-0.1),vec3(1.0),intensity,90.,-50.+sin(iTime*1.4)*5.,20.,-50.);
    col = mix(col,d.rgb,S(d.w,0.));      
    
    d = light2D(p,vec2(-0.4,-0.15),vec3(1.0),intensity,90.,-180.+sin(-iTime*1.5)*5.,20.,90.);
    col = mix(col,d.rgb,S(d.w,0.));
    d = light2D(p,vec2(0.4,-0.15),vec3(1.0),intensity,90.,0.+sin(iTime*1.5)*5.,20.,-90.);
    col = mix(col,d.rgb,S(d.w,0.));      
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-0.5*iResolution.xy)/iResolution.y;

    vec3 col = vec3(0.0,0.0,0.0);
    col = bgEffect(uv,col);
    
    col = bg(uv,col);
    col = lightsSystemBack(uv,col);
    col = lightsSystemMain(uv,col);
    
    float brightness = 1.5;
    fragColor = vec4(col*brightness,1.0);
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
