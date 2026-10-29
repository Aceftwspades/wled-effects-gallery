// another regular polygon by jonasfrey - https://www.shadertoy.com/view/XXVSzG - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: another regular polygon (jonasfrey)
// another regular polygon by jonasfrey
// https://www.shadertoy.com/view/XXVSzG
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// regular polygons
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
// signed distance to a n-star polygon with external angle en
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
float f_n_sdist_rpolyg(in vec2 p, in float r, in int n )
{
    // these 4 lines can be precomputed for a given shape
    float an = 3.141593/float(n);
    vec2  acs = vec2(cos(an),sin(an));

    // reduce to first sector
    float bn = mod(atan(p.x,p.y),2.0*an) - an;
    p = length(p)*vec2(cos(bn),abs(sin(bn)));

    // line sdf
    p -= r*acs;
    p.y += clamp( -p.y, 0.0, r*acs.y);
    return length(p)*sign(p.x);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 o_trn = (fragCoord.xy-iResolution.xy*.5)/iResolution.yy;
    o_trn*=2.;
    float n_its = 33.;
    
    float n_tau = 6.2831;
    vec4 o_col_min = vec4(0.);
    vec4 o_col = vec4(0.);
    float n_min = 1.;
    float n_ang_nor = fract((atan(o_trn.y, o_trn.x)/n_tau));
    for(float n_it_nor = .0; n_it_nor<1.;n_it_nor+=(1./n_its)){
        
        float n_radius = n_it_nor+(sin((iTime+n_it_nor*3.)*n_tau)*.5+.5)*(1./n_its/2.);
        
        
        int n_lines = 5;
        float n_rad = sin((iTime*.2+n_it_nor)*n_tau)*(1.-n_radius);
        mat2 o_rot = mat2(-sin(n_rad), cos(n_rad), cos(n_rad), sin(n_rad));
        vec2 o = o_trn * o_rot;
        float n = f_n_sdist_rpolyg(
            o, 
            n_radius,
            n_lines
        );
        
        n = abs(n);
        n_min = min(n, n_min);
        n = n/n_radius;
        
        n = pow(n, 1./n_its)*0.95;//*2.01;//*(1.+1./9.);
        n = clamp(n, 0., 1.);
        n = 1.-n;
        //n = 1.-pow(abs(1.-n), 2.);
        float n3 = (sin((iTime*.02+n_it_nor)*n_tau)*.5+.5);
        o_col += vec4(n)*vec4(n3, 1.-n3, fract(.5+n3), 1.);
        
    }
    
    float n2 = pow(n_min, 1./4.);
    fragColor = o_col*(1.-n2);
    //fragColor = sqrt(fragColor);
    //fragColor = vec4(n2);
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
