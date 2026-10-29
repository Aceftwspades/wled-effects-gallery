// other shine star by nayk - https://www.shadertoy.com/view/XcfczB - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: other shine star (nayk)
// other shine star by nayk
// https://www.shadertoy.com/view/XcfczB
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// combination of  https://www.shadertoy.com/view/lslyRn https://www.shadertoy.com/view/7lKSDz and fbm mix
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end

#define iterations 15
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.000 

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850
#define NUM_OCTAVES 5
#define time iTime
#define resolution iResolution.xy
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
			p=abs(p)/dot(p,p)-formuparam; // the magic formula
			a+=abs(length(p)-pa); // absolute sum of average change
			pa=length(p);
		}
		float dm=max(0.,darkmatter-a*a*.001); //dark matter
		a*=a*a; // add contrast
		if (r>6) fade*=1.05-dm; // dark matter, don't render near
		//v+=vec3(dm,dm*.5,0.);
		v+=fade;
		v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
		fade*=distfading; // distance fading
		s+=stepsize;
	}
	v=mix(vec3(length(v)),v,saturation); //color adjust
	fragColor = vec4(v*.01,1.);	
}


mat3 rotX(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat3(
    1, 0, 0,
    0, c, -s,
    0, s, c
    );
}
mat3 rotY(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat3(
    c, 0, -s,
    0, 1, 0,
    s, 0, c
    );
}

float random(vec2 pos) {
    return fract(sin(dot(pos.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 pos) {
    vec2 i = floor(pos);
    vec2 f = fract(pos);
    float a = random(i + vec2(0.0, 0.0));
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 pos) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));
    for (int i=0; i<NUM_OCTAVES; i++) {
        v += a * noise(pos);
        pos = rot * pos * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}
#define time iTime

const float PI = 3.1415925358;

float safety_sin( in float x ) { return sin( mod( x, PI ) ); }

float rand( vec2 p ) { return fract( safety_sin( dot(p, vec2( 12.9898, 78.233 ) ) ) * 43758.5453 + time * .35 ); }

float noise2( vec2 x )
{
	vec2 i = floor(x);
	vec2 f = fract(x);
	vec4 h;
	// Smooth Interpolation
	f = f * f * ( f * -2.0 + 3.0 );
	// Four corners in 2D of a tile
	h.x = rand( i + vec2( 0., 0. ) );
	h.y = rand( i + vec2( 1., 0. ) );
	h.z = rand( i + vec2( 0., 1. ) );
	h.w = rand( i + vec2( 1., 1. ) );
	// Mix 4 coorners porcentages
	return mix( mix( h.x, h.y, f.x ), mix( h.z, h.w, f.x ), f.y );
}

float star_burst( vec2 p )
{
	float k0 = 2.0;
	float k1 = 1.0;
	float k2 = 0.5;
	float k3 = 12.0;
	float k4 = 12.0;
    float k5 = 2.0;
    float k6 = 5.2;
    float k7 = 4.0;
    float k8 = 6.2;
	
	float l  = length( p );
    float l2 = pow( l * k1, k2 );
	float n0 = noise2( vec2( atan(  p.y,  p.x ) * k0, l2 ) * k3 );
	float n1 = noise2( vec2( atan( -p.y, -p.x ) * k0, l2 ) * k3 );
	float n  = pow( max( n0, n1 ), k4 ) * pow( clamp( 1.0 - l * k5, 0.0, 1.0 ), k6 );
	n += pow( clamp( 1.0 - ( l * k7 - 0.1 ), 0.0, 1.0 ), k8 );
	return n;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//get coords and direction
	vec2 uv=fragCoord.xy/iResolution.xy-.5;
	uv.y*=iResolution.y/iResolution.x;
    	uv*=fract(-iTime*1.1);
	vec3 dir=vec3(uv*zoom,iTime*0.009);

vec2 p = (gl_FragCoord.xy * 2.0 - resolution.xy) / min(resolution.x, resolution.y);

    float t = 0.0, d;

    float time2 = 2.6 * time / 5.0;

    vec2 q = vec2(0.0);
    q.x = fbm(p + 0.00 * time2);
    q.y = fbm(p + vec2(1.0));
    vec2 r = vec2(0.0);
    r.x = fbm(p + 1.0 * q + vec2(1.7, 9.2) + 0.15 * time2);
    r.y = fbm(p + 1.0 * q + vec2(8.3, 2.8) + 0.126 * time2);
    float f = fbm(p + r);
    vec3 color = mix(
    vec3(1.90, 0.2, 0.1),
    vec3(1.50, 0.07, 0.07),
    clamp((f * f) * 4.0, 1.0, 0.0)
    );

    color = mix(
    color,
    vec3(0.3, 0.5, 0.90),
    clamp(length(q), 1.0, 2.0)
    );
 vec2 p2 = fragCoord / min( iResolution.x, iResolution.y );
    
    p2 -= 0.5; p2.x -= 0.35;
    p2 *= 0.5;
    
	float r2 = star_burst( p2 * 1.1 );
	float g = star_burst( p2 );
	float b = star_burst( p2 * 0.2 );

    // Output to screen
    vec3 col = pow( vec3( r2, g, b ), vec3( 1.0 / 2.2 ) );

    color = mix(
    color,
    vec3(.0, 1.0, 0.0),
    clamp(length(r.y), 0.2, 0.0)
    );

    color = ( f + 1.09 * f * + 0.8 * f) * color;

	vec3 from=vec3(1.,.5,0.5)*col;
	
	
	mainVR(fragColor, fragCoord, from, dir);	
    fragColor+=vec4(color+col,1.);
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
