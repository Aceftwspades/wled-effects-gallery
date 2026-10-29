// Frame t 2 by shadertoyjiang - https://www.shadertoy.com/view/MfXyz7 - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: Frame t 2 (shadertoyjiang)
// frame t 2  by shadertoyjiang
// https://www.shadertoy.com/view/MfXyz7
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// t
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end


#define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))

int obj;

// 
float sdinvFrame(vec3 p)
{
        float riv = 1.;
        vec3 q = p,   y = iTime*vec3(1,3,7)*.1;
        q = q * riv / dot(q,q);
        q -= y;
        vec3 i = round(q) ;
        q = q - i;
        vec3 a = abs(q), s = sign(q);//step(0., q);
        vec3 m = step(a,a.yzx )*step(a,a.zxy);
        q = q * m + s * (1. - m)*.5 + i+y;
        q = q * riv / dot(q,q);
        float d = length(p-q);
        return d - .06;
}

float sdInvFace(vec3 p)
{
        float riv = 1.;
        vec3 q = p,   y = iTime*vec3(1,3,7)*.1;
        q = q * riv / dot(q,q);
        q -= y;
        vec3 i = round(q) ;
        q = q - i;
        vec3 a = abs(q), s = sign(q);
        vec3 m = step(a.yzx,a )*step(a.zxy,a );
        q = q * (1.-m) + s * m*.5 + i+y;
        q = q * riv / dot(q,q);
        float d = length(p-q);
        return d - .0;
}

vec2 sdaaa(vec3 p)
{
        float d1 = sdinvFrame(p);
        float d2 = sdInvFace(p);
        obj=1;
        if(d2<d1)obj=2;
        return vec2(min(d1,d2),d2);
}

vec2 map(vec3 p)
{
        float t = iTime+5.;
        vec2 ms = iMouse.xy/iResolution.xy*6.28+t;
        p.xy = p.xy * rot(t +1.);
        p.xz = p.xz * rot(ms.x);
        p.yz = p.yz * rot(ms.y);
        return sdaaa(p);
}

void mainImage(out vec4 O, vec2 U)
{
        O = vec4(.75,.6,.1,1)*.2;
        vec2 R = iResolution.xy,cd,
             u = (U+U - R) / R.y;
        vec3 eye = vec3(0, 0, -5),
             dir = normalize(vec3(u, 2)),
             sun = 5. * ( .2*cos(iTime+vec3(7,11,13)) + vec3(-1,2,-3)/3.74 ),
             eps = vec3(0, .0001, 0),
             nor, p;
        float d , t=0., ki=1.;
        for(int i=0; i<128 ;i++)
        {
                if(t>30.)break;
                p = eye + dir * t;
                cd = map(p);
                d = cd.x;
                if( d<.01 )
                {       //  
                        nor = normalize(vec3(map(p+eps.yxx).x, map(p+eps).x, map(p+eps.xxy).x)-d); 
                        vec3  sp = normalize(sun-p), ep=normalize(eye-p);
                        float ln = max(0., dot(nor,sp)),               // light norm
                              er = max(0., dot(ep, reflect(-sp,nor))); // eye ray
                        float ambt=.3, difu=.6, spec=80.;
                        vec4  lightClr = vec4(1,.5,0,1);
                        

                        if(obj==1){
                          O = O     + lightClr * (ambt + difu*ln + pow(er, spec)) * ki     ;
                            
                          return;
                        }
                        ki*=.8 ;
                }
                O = O +    exp( -120.* cd.y )*vec4(.1,.1,.2,1)*.1;
                t += max(.003, d * .4 ) ;
        }
        //O = log(1.+O);
        //O = vec4(.5,0,0,1);
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
