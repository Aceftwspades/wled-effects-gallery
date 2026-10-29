// 2D SDF Dance remake by nayk - https://www.shadertoy.com/view/McscR4 - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: 2D SDF Dance remake (nayk)
// 2D SDF Dance remake by nayk
// https://www.shadertoy.com/view/McscR4
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// originals https://www.shadertoy.com/view/MXK3WG
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
#define PI (3.14159265)
#define TAU (2.*PI)

#define sum3(V) (V.x+V.y+V.z)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // scaled so (0,0) is in center of screen, adjusted for aspect ratio
    vec2 uv = (2.*fragCoord - iResolution.xy ) / iResolution.y;
    uv*=2.5;
float t = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv.xy) + .57)) * 2.2;
	float si = sin(t);
	float co = cos(t);
	mat2 ma = mat2(co, si, -si, co);
    uv*=ma;
    vec3 col = vec3(0.);

    for (float i = 5.; i < 70.; i ++)
        col += (.5+.5*sin(vec3(TAU/1.,TAU/2.,TAU*1./3.)+i*2.47) )// color
          *.05/distance(uv+0.01*cos(i)*1.*trunc(iTime*1.1+i),
            vec2(sin(iTime*i/13.-i)+cos(i),cos(iTime*i/13.+i))*0.8)+sin(i);

    col = clamp(col,0.,3.5);

   
    col = sqrt(col)*2.-1.;

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
