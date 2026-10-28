// particle in square by nayk - https://www.shadertoy.com/view/McfyRn - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: particle in square (nayk)
// particle in square by nayk
// https://www.shadertoy.com/view/McfyRn
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// from  https://glslsandbox.com/e#82116.0 https://glslsandbox.com/e#94360.0 and other
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end


#define rotation 1


uniform vec2 mouse;

#define resolution iResolution.xy
#define time iTime

// stuff
#define rot( a )	mat2( cos(a), -sin(a), sin(a), cos(a) )
#define res resolution
#define nsin( a )       sin( a )*.5+.5

float c = 0.0;

float circle( vec2 p, float r )
{
	return step( length( p ), r);
}

vec2 translate(vec2 pos, vec2 translate) {
	return pos + vec2(-translate.x, -translate.y);
}

mat2 rotate2D(float a) {
	float co = cos(a), si = sin(a);
	return mat2(co, -si, si, co);
}

float sdBox(in vec2 p, in vec2 size) {
	p = abs(p) - size;
	return length(max(p, 0.0)) + min(8.0, max(p.x, p.y));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p;
     
 
    p = ( 2.*gl_FragCoord.xy - res )/min( res.x, res.y );

   
    p *= rot( time*5. );
  
highp vec2 size = vec2(resolution.x, resolution.y);
	
	vec2 uv = (2.0 * gl_FragCoord.xy - size) / size.x;
	uv = translate(uv, vec2(0.0));
	uv *= rotate2D(1.1*time);
	
	highp vec3 color = vec3(0.0);
	
	float box = sdBox(uv, vec2(0.3));
	
	color = mix(color, vec3(1.0), 1.0-smoothstep(0.0,0.2, abs(box)));
	color.r *= 1.01;
	
	color = pow(color,vec3(32.0));
    float dist = mod(sqrt( floor( time*30./52. ) ),6.0);	
  
    float l = sqrt( 3. )/dist;
    float s =     ( 1. )/dist;
    float n =     ( 2. )/dist;

    // well i guess here comes the hardcoded stuff
    c = circle(  (p), 1.0 );
    
    float size2 = 0.05;
	float dist2 = 0.100;
	float ang = 0.0;
	vec2 pos = vec2(0.0,0.0);
	vec3 color2 = vec3(0.2);;
	
	for(int i=0; i<50; i++){
		float r = 0.3;
		ang += 3.14 / (float(50)*0.5)+(time/60.0);
		pos = vec2(cos(ang),sin(ang))*r*sin(time+ang/.3);				  
		dist2 += size2 / distance(pos,uv);
		vec3 c2 = vec3(0.03, 0.05, 0.1);
		color2 = c2*dist2;
	}	
    p.x -= l;
    p.y -= s;
    c += circle(  (p), 1.0 );
    p.x += l;
    p.y -= s;
    c += circle(  (p), 1.0 );
    p.x += l;
    p.y += s;
    c += circle(  (p), 1.0 );
    p.x -= 0.;
    p.y += n;
    c += circle( (p), 1.0 );
    p.x -= l;
    p.y += s;
    c += circle(  (p), 1.0 );
    p.x -= l;
    p.y -= s;
    c += circle(  (p), 1.0 );
	
    // white + white = black
    c = mod( ceil(c)+color.x, 2.0 );
    
    fragColor = vec4(c*color2.y, c*color2.z, c*color2.x, 1.0);
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
