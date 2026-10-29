// triangle thing 2 by jonasfrey - https://www.shadertoy.com/view/4cXcWN - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: triangle thing 2 (jonasfrey)
// triangle thing 2 by jonasfrey
// https://www.shadertoy.com/view/4cXcWN
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// triangle circle thing
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 o_trn = ( fragCoord.xy - iResolution.xy*.5 ) / iResolution.yy;
    o_trn*=1.5;
    float n = (length(o_trn)-.5)/.5;
    
    float n_its = 33.; 
    float n_it_one_nor = 1./n_its;
    float n_tau = 6.2831;
    vec4 o_col = vec4(0.);
    for(float n_it_nor = 0.; n_it_nor<1.; n_it_nor+=n_it_one_nor){
    
        float n_radians = n_tau * n_it_nor;
        float n_radius = sin(iTime*0.5+n_it_nor*n_tau*3.)*.5;
        vec2 o_p = vec2(
            sin(n_radians), 
            cos(n_radians)
        )*n_radius;
        float n = length(o_trn-o_p);
        float n_circ_rad = (sin(iTime*.5+(n_it_nor*3.+.25)*n_tau)*.5+.5)*0.15;
        n = (n-n_circ_rad)/n_circ_rad;// signed distance field
        n = 1.-pow(abs(n), 1./5.);
        n = clamp(n, 0., 1.);
        vec4 o_c = vec4(n_it_nor, 1.-n_it_nor, fract(n_it_nor+.5), 1.);
        o_col += o_c*n;
        //o_col += vec4(n);
    }
    fragColor = o_col;
    //fragColor = sqrt(fragColor);

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
