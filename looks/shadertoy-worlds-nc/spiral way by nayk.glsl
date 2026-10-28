// spiral way by nayk - https://www.shadertoy.com/view/lclczn - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: spiral way (nayk)
// spiral way by nayk
// https://www.shadertoy.com/view/lclczn
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// original from glslsandbox and shadertoy
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
#define  time iTime
#define resolution iResolution.xy


void mainImage( out vec4 fragColor, in vec2 fragCoord ){
 vec2 uv = fragCoord/iResolution.xy-0.5;
vec2 pos = uv*0.5;
    vec2 pos2 = uv*.02;
float t3 = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv.xy) + .07)) * 2.2;
float si = sin(t3);
float co = cos(t3);
mat2 ma = mat2(co, si, -si, co);
    pos*=ma;
const float pi = 85.14159;
const float n = 2.0;

   
 
const float n2 = 16.0;

float radius2 = length(pos2) *5.5 - 0.4;
float t2 = atan(pos2.y, pos2.x);

float color2 = 0.0;

for (float i = 9.0; i <= n2; i++){
color2 += 0.012 / abs(0.2 * cos(
3. * (t2+ i/n2 * +time *1.1)
   ) + tan(dot(radius2,pi-tan(time*1.2)))
);
}
   
float radius = length(pos) * 2.0 - 0.4;
    pos*=ma;
float t = atan(pos.y, pos.x);

float color = 0.025;

for (float i = 1.0; i <= n; i++){
color += 0.051 / abs(1. * sin(
4. * ((t) + i/n * time * .25)
   ) - sqrt(ceil(radius))
);
}

fragColor = vec4(vec3(1.5, 0.3, 1.15) * color, 8.);
    fragColor+= vec4(vec3(.5, 0.5, 1.15) * color2, 9.);

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
