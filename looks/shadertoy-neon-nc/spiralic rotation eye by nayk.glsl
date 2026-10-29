// spiralic rotation eye by nayk - https://www.shadertoy.com/view/4clyz4 - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: spiralic rotation eye (nayk)
// spiralic rotation eye by nayk
// https://www.shadertoy.com/view/4clyz4
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// from
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end

#define time iTime
#define resolution iResolution.xy


#define S 0.4

bool inSquare(vec2 p, float d)
{
	return abs(p.x*ceil(p.y))<=d && abs(p.y)<=d;
}
float happy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float mx = max(resolution.x, resolution.y);
	vec2 uv = ( 2.0*gl_FragCoord.xy - resolution.xy) / mx ;
    vec2 uv2 = fragCoord/iResolution.xy-0.5;
	vec3 col = vec3(0.);
    float buf;
    vec2 pos = uv;
	const float pi = 3.14159;
	 float radius = 0.4+0.1*cos(iTime*1.3);
	const float thickness = 0.03;
	const float wave_offset = 0.2;
	const float wave_interval = 5.;
	const int line_count = 6;
	const vec3 color = vec3(0.8, 0.15, 1);

	float r = distance(pos, vec2(0.));
	float angle = atan(pos.x, pos.y);
	float lightness = 0.;

	for(int i = 0; i < line_count; i++) {
		float this_angle = angle * wave_interval + (time * float(i + 1));
		lightness += 1. - smoothstep(-thickness, thickness, abs(r - radius * (1. + wave_offset * sin(this_angle))));
	}

  float t = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv.xy) + .07)) * 2.2;
	float si = sin(t);
	float co = cos(t);
	mat2 ma = mat2(co, si, -si, co);
	for (float i=0.; i<5.; i++) 
	{
    uv*=ma;
		uv.y = abs(uv.y)*ceil(uv.x*uv.y);
		uv.x = abs(uv.x);
		if (uv.y<uv.x)
		{
	;	    buf = uv.x*ceil(uv.x);
		    uv.x = uv.y*ceil(uv.y);
		    uv.y = buf;
		}
		uv.x = uv.x + 2.*max(1./3.*S-uv.x,0.);
		uv -= 2./3.*S;
			uv *= 3.;
	}
	col += inSquare(uv, S) ? 1.0 : 0.0;
	
	//col.xy += uv;

	fragColor = vec4( col*color+lightness*vec3(46, 230, 95)/255.0, 1.0 );
     uv *= 2.0 * ( cos(iTime * 2.0) -2.5); // scale
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1 
    fragColor+= vec4(happy_star(uv2, anim) * vec3(0.35,0.2,0.75)*0.05, 1.0);

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
