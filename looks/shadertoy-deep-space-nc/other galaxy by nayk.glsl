// other galaxy by nayk - https://www.shadertoy.com/view/XfXyW4 - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: other galaxy (nayk)
// other galaxy by nayk
// https://www.shadertoy.com/view/XfXyW4
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// combination of https://www.shadertoy.com/view/lXsSRN https://www.shadertoy.com/view/MdXSzS https://www.shadertoy.com/view/lslyRn https://www.shadertoy.com/view/wdtczM
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end


#define iterations 14
#define formuparam 0.50

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.000 

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850


void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 ro, in vec3 rd )
{
	//get coords and direction
	vec3 dir=rd;
	vec3 from=ro;
	
	//volumetric rendering
	float s=0.1,fade=1.;
	vec3 v=vec3(0.);
	for (int r=0; r<volsteps; r++) {
		vec3 p=from+s*dir*.5;
		p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) { 
			p=abs(p)/dot(p,p)-formuparam;
            // the magic formula
			a+=abs(length(p)-pa); // absolute sum of average change
			pa=length(p);
		}
		float dm=max(0.,darkmatter-a*a*.001); //dark matter
		a*=a*a; // add contrast
		if (r>6) fade*=1.2-dm; // dark matter, don't render near
		//v+=vec3(dm,dm*.5,0.);
		v+=fade;
		v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
		fade*=distfading; // distance fading
		s+=stepsize;
	}
	v=mix(vec3(length(v)),v,saturation); //color adjust
	fragColor = vec4(v*.04,1.);	
}
float hash( ivec3 p )    // this hash is not production ready, please
{                        // replace this by something better

    // 3D -> 1D
    int n = p.x*3 + p.y*113 + p.z*311;

    // 1D hash by Hugo Elias
	n = (n << 13) ^ n;
    n = n * (n * n * 15731 + 789221) + 1376312589;
    return float( n & ivec3(0x0fffffff))/float(0x0fffffff);
}

float noise( in vec3 x )
{
    ivec3 i = ivec3(floor(x));
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
	
    return mix(mix(mix( hash(i+ivec3(0,0,0)), 
                        hash(i+ivec3(1,0,0)),f.x),
                   mix( hash(i+ivec3(0,1,0)), 
                        hash(i+ivec3(1,1,0)),f.x),f.y),
               mix(mix( hash(i+ivec3(0,0,1)), 
                        hash(i+ivec3(1,0,1)),f.x),
                   mix( hash(i+ivec3(0,1,1)), 
                        hash(i+ivec3(1,1,1)),f.x),f.y),f.z);
}

// https://www.shadertoy.com/view/XsGfWV
vec3 aces_tonemap(vec3 color){	
	mat3 m1 = mat3(
        0.59719, 0.07600, 0.02840,
        0.35458, 0.90834, 0.13383,
        0.04823, 0.01566, 0.83777
	);
	mat3 m2 = mat3(
        1.60475, -0.10208, -0.00327,
        -0.53108,  1.10813, -0.07276,
        -0.07367, -0.00605,  1.07602
	);
	vec3 v = m1 * color;    
	vec3 a = v * (v + 0.0245786) - 0.000090537;
	vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
	return pow(clamp(m2 * (a / b), 0.0, 1.0), vec3(1.0 / 2.2));	
}

vec2 r(vec2 p, float a) { return p*mat2(cos(a), sin(a), -sin(a), cos(a)); }
#define R iResolution.xy
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//get coords and direction
	vec2 uv=fragCoord.xy/iResolution.xy-.5;
    vec4 O = fragColor; vec2 I = fragCoord;
      vec2 uv3 = I/R;
	uv.y*=iResolution.y/iResolution.x;
	vec3 dir=vec3(uv*zoom,iTime*0.005);
	float time=iTime*speed+.25;
     vec2 uv2 = fragCoord / iResolution.xy;
 vec2 adjustedUV = (uv2 - 0.5) * 3.5;
    float timeFactor = iTime * 0.025;
    vec4 outputColor = vec4(0.0);
    float x;
    float t = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv.xy) + .07)) * 2.2;
	float si = sin(t);
	float co = cos(t);
	mat2 ma = mat2(co, si, -si, co);
    vec4 o = fragColor;
 vec2 R2 = iResolution.xy; 
    o-=o;
    for(float d,t = -iTime*.1, i = 0. ; i > -1.; i -= .06 )          	
    {   d = fract( i -3.*t );                                          	
        vec4 c = vec4( ( I - R2 *.5 ) / R2.y *d ,i,0 ) * 28.;            	
        for (int j=0 ; j++ <27; )                                      	
            c.xzyw = abs( c / dot(c,c)                                 	
                    -vec4( 7.-.2*sin(t) , 6.3 , .7 , 1.-cos(t/.8))/7.);	
       o -= c * c.yzww  * d--*d  / vec4(3,5,1,1);                     
    }
	float v1, v2, v3;
	v1 = v2 = v3 = 0.0;
	 
    vec2 p = (2.*I - R) / R.y * 1.5;
    
    float fp = pow(.5/length(pow(abs(r(p,.43))
        *vec2(2,1),vec2(.5))),4.5);
       
    p *= mat2(.7,-.5,-.4,1.2);    
    vec3 pos = normalize(vec3(r(p,-.4/length(p)),.25));
    pos.z -= iTime*1.1;
    
    vec3 q = 6.*pos;
    float f  = 0.5000*noise( q ); q = q*2.;
          f += 0.2500*noise( q ); q = q*2.;
          f += 0.1250*noise( q ); q = q*2.;
          f += 0.0625*noise( q );
    
    vec2 n = uv3*(1.-uv)*3.; float v = pow(n.x*n.y,.8);
    
    float fr = .6/length(p);
    f = smoothstep(-.4,2.,f*f) * fr*fr + fp;
    
    O = vec4(aces_tonemap(
        pow(f*f * vec3(1., .05, 1.0)*v,vec3(.45))*3.5),0);
	float s = 0.0;
	for (int i = 0; i < 90; i++)
	{
		vec3 p = s * vec3(uv, 0.0);
	
		p += vec3(.22, .3, s - 1.5 - sin(iTime * .13) * .1);
		for (int i = 0; i < 8; i++)	p = abs(p) / dot(p,p) - 0.659;
		v1 += dot(p,p) * .0015 * (1.8 + sin(length(uv.xy * 13.0) + .5  - iTime * .2));
		v2 += dot(p,p) * .0013 * (1.5 + sin(length(uv.xy * 14.5) + 1.2 - iTime * .3));
		v3 += length(p.xy*10.) * .0003;
		s  += .035;
	}
	
	float len = length(uv);
	v1 *= smoothstep(.7, .0, len);
	v2 *= smoothstep(.5, .0, len);
	v3 *= smoothstep(.9, .0, len);
	
	vec3 col = vec3( v3 * (1.5 + sin(iTime * .2) * .4),
					(v1 + v3) * .3,
					 v2) + smoothstep(0.2, .0, len) * .85 + smoothstep(.0, .6, v3) * .3;
    vec3 color;
    for (float waveIndex = 0.0; waveIndex < 25.0; waveIndex += 1.0) {
        vec2 waveVector = vec2(cos(x = waveIndex * 15. - timeFactor), sin(x));
        float wave = sin(waveIndex * mix(0.05, 0.5, sin(timeFactor) * 0.5) - timeFactor);
        float distance = length(adjustedUV - wave * waveVector); 
        
        for(int i=0;i<3;i++) {
            float z = waveIndex * 0.000002;
            float l = distance;
            vec2 uv = adjustedUV;
            uv += waveVector/l*(sin(z)+5.)*abs(sin(l*1.1-z-z));
            color[i] = 0.0013/length(mod(uv + vec2(0.003 * float(i-1)),1.1)-0.5); 
        }
        color *= vec3(0.49, 0.49, 1.0)+o.xyz; 
        outputColor += vec4(color / distance, 2.0);
    }
	
    
	vec3 from=vec3(1.,.5,0.5);
	
	
	mainVR(fragColor, fragCoord, from, dir);	
    fragColor*=outputColor*5.;
    fragColor*=O*2.;
    fragColor*=vec4(min(pow(abs(col), vec3(1.0)), 1.0), 1.0);
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
