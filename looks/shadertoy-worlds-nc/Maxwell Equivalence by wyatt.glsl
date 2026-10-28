// Maxwell Equivalence by wyatt - https://www.shadertoy.com/view/4csyW4 - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: Maxwell Equivalence (wyatt)
// Maxwell Equivalence by wyatt
// https://www.shadertoy.com/view/4csyW4
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// Shown are 3 versions of the Maxwell equations. The part that changes is the treatment of magnetic materials. I have no clue which is "correct". They all converge to the same thing
//@ common
#define R iResolution.xy
#define Main void mainImage(out vec4 Q, in vec2 U)
#define A(U) texture(iChannel0,(U)/R)
#define B(U) texture(iChannel1,(U)/R)
#define C(U) texture(iChannel2,(U)/R)
#define D(U) texture(iChannel3,(U)/R)
//@ buffer A
//@ iChannel0 = A
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
Main {
    Q = A(U);
    vec4 n = A(U+vec2(0,1));
    vec4 e = A(U+vec2(1,0));
    vec4 s = A(U-vec2(0,1));
    vec4 w = A(U-vec2(1,0));
    float j = 0.;
    if (length(U-vec2(.2,.5)*R) < 10.) {
        j = 1.;
    }
    if (length(U-vec2(.4,.5)*R) < 10.) {
        j = -1.;
    }
    float mu = 1.;
    if ((U.x > .25*R.x && U.y > .2*R.y && U.x < .75*R.x && U.y < .8*R.y) && (U.x > .65*R.x || U.y > .65*R.y || U.x < .35*R.x || U.y < .35*R.y)) {
        mu = 1000.;
    }
    
    if (iFrame%2==0) {
        Q.xy -= 0.5*vec2(n.z-s.z,w.z-e.z)/mu;
    } else {
        Q.z  -= 0.5*(n.x-s.x+w.y-e.y) - j;
    }
    Q.z *= .9999;
    if (U.x < 10.||R.x-U.x < 10.||R.y - U.y < 10.||U.y < 10.) Q *= .9;

}
//@ buffer B
//@ iChannel0 = B
//@ iChannel1 = D
//@ iChannel2 = none
//@ iChannel3 = none
Main {
    Q = A(U);
    vec4 n = A(U+vec2(0,1));
    vec4 e = A(U+vec2(1,0));
    vec4 s = A(U-vec2(0,1));
    vec4 w = A(U-vec2(1,0));
    float j = 0.;
    if (length(U-vec2(.2,.5)*R) < 10.) {
        j = 1.;
    }
    if (length(U-vec2(.4,.5)*R) < 10.) {
        j = -1.;
    }
    float mu = 1.;
    if ((U.x > .25*R.x && U.y > .2*R.y && U.x < .75*R.x && U.y < .8*R.y) && (U.x > .65*R.x || U.y > .65*R.y || U.x < .35*R.x || U.y < .35*R.y)) {
        mu = 1000.;
    }
    
    if (iFrame%2==0) {
        Q.xy -= 0.5*vec2(n.z-s.z,w.z-e.z) + (mu-1.)/1000.*B(U).xy;
    } else {
        Q.z  -= 0.5*(n.x-s.x+w.y-e.y) - j;
    }
    
    if (U.x < 10.||R.x-U.x < 10.||R.y - U.y < 10.||U.y < 10.) Q *= .9;

}
//@ buffer C
//@ iChannel0 = C
//@ iChannel1 = D
//@ iChannel2 = none
//@ iChannel3 = none
Main {
    Q = A(U);
    vec4 n = A(U+vec2(0,1));
    vec4 e = A(U+vec2(1,0));
    vec4 s = A(U-vec2(0,1));
    vec4 w = A(U-vec2(1,0));
    
    vec4 N = B(U+vec2(0,1));
    vec4 E = B(U+vec2(1,0));
    vec4 S = B(U-vec2(0,1));
    vec4 W = B(U-vec2(1,0));
    float j = 0.;
    if (length(U-vec2(.2,.5)*R) < 10.) {
        j = 1.;
    }
    if (length(U-vec2(.4,.5)*R) < 10.) {
        j = -1.;
    }
    float mu = 1.;
    if ((U.x > .25*R.x && U.y > .2*R.y && U.x < .75*R.x && U.y < .8*R.y) && (U.x > .65*R.x || U.y > .65*R.y || U.x < .35*R.x || U.y < .35*R.y)) {
        mu = 1000.;
    }
    
    if (iFrame%2==0) {
        Q.xy -= .5*vec2(n.z-s.z,w.z-e.z);
    } else {
        Q.z  -= .5*(n.x-s.x+w.y-e.y-N.z+S.z-W.w+E.w) - j;
    }
    
    if (U.x < 10.||R.x-U.x < 10.||R.y - U.y < 10.||U.y < 10.) Q *= .9;

}
//@ buffer D
//@ iChannel0 = B
//@ iChannel1 = C
//@ iChannel2 = D
//@ iChannel3 = none
Main {

    Q = C(U);
    float mu = 1.;
    if ((U.x > .25*R.x && U.y > .2*R.y && U.x < .75*R.x && U.y < .8*R.y) && (U.x > .65*R.x || U.y > .65*R.y || U.x < .35*R.x || U.y < .35*R.y)) {
        mu = 1000.;
    }
    if (iFrame%2==1) {
        Q.xy = (1.-1./mu)*A(U).xy;
        Q.zw = (1.-1./mu)*B(U).xy;
    }
}
//@ image
//@ iChannel0 = A
//@ iChannel1 = B
//@ iChannel2 = C
//@ iChannel3 = D
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
Main {

    float mu = 1.;
    if ((U.x > .25*R.x && U.y > .2*R.y && U.x < .75*R.x && U.y < .8*R.y) && (U.x > .65*R.x || U.y > .65*R.y || U.x < .35*R.x || U.y < .35*R.y)) {
        mu = 1000.;
    }
    
    Q = A(U);
    if (U.x < .5*R.x) Q = B(U);
    if (U.y > .5*R.y) Q = C(U)/mu;
    if (mu>1.) Q *= 10.;
    Q = sin(-2.+length(Q.xy)+vec4(1,2,3,4));
    
    

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
