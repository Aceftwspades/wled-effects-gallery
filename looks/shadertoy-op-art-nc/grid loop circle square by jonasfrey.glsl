// grid loop circle square by jonasfrey - https://www.shadertoy.com/view/lcsyWM - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: grid loop circle square (jonasfrey)
// grid loop circle square by jonasfrey
// https://www.shadertoy.com/view/lcsyWM
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// a simple loop animation
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
// Fork of "triangle thing 2" by jonasfrey. https://shadertoy.com/view/4cXcWN
// 2024-07-17 08:10:00
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end

float f_n_sdf_rectangle( in vec2 o_p, in vec2 o_sidelength )
{
    vec2 o_d = abs(o_p)-o_sidelength;
    return length(max(o_d,0.0)) + min(max(o_d.x,o_d.y),0.0);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 o_trn = ( fragCoord.xy - iResolution.xy*.5 ) / iResolution.yy;
    o_trn*=1.5;
    float n = (length(o_trn)-.5)/.5;
    float nt = iTime *0.5;
    vec2 o_scl = vec2(6., 6.);
    vec2 o_scl_one = 1./ o_scl; 
    
    float n_its = o_scl.x*o_scl.y;
    float n_it_one_nor = 1./n_its;
    float n_tau = 6.2831;
    vec4 o_col = vec4(0.);
    float n_min = 1.;
    for(float n_it_nor = 0.; n_it_nor<1.; n_it_nor+=n_it_one_nor){
    
        float n_it = floor(n_it_nor*n_its);
        float n_radians = n_tau * n_it_nor;
        vec2 o_p = o_trn-vec2(
            fract(n_it_nor*o_scl.x), 
            floor(n_it_nor*o_scl.x)*(1./o_scl.x)
        )+.5;
        
        float nl = 1.-clamp(fract(n_it_nor+sin(iTime*0.5))*12.,0.,1.);
        nl = sin(nl*n_tau/2.);
        float n_size = .5+nl;
        float n = f_n_sdf_rectangle(o_p, (1./o_scl/2.).yx*n_size);
        float nc = length(o_p)-max(o_scl_one.x, o_scl_one.y)*.5*n_size;
        n = nl*n + (1.-nl)*nc;
        n /= n_size;
        n_min = min(n_min, n);
        //n = (n-n_size)/n_size;// signed distance field
        n = 1.-pow(abs(n), 1./12.);
        n = clamp(n, 0., 1.);
        vec4 o_c = vec4(n_it_nor, 1.-n_it_nor, fract(n_it_nor+.5), 1.);
        o_col += o_c*n;
        //o_col += vec4(n);
    }
    float n2 = 1.-pow(abs(n_min), 1./9.);
    fragColor = o_col*n2*2.;
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
