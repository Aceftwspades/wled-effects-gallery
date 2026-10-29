// Adventure by wyatt - https://www.shadertoy.com/view/MffcR2 - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: Adventure (wyatt)
//  Adventure by wyatt
// https://www.shadertoy.com/view/MffcR2
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// textures:
//   Buffer A's iChannel0 was a texture on Shadertoy - choose a picture of your own for it beside the deck's channels (noise until then)
//   Image's iChannel2 was a texture on Shadertoy - choose a picture of your own for it beside the deck's channels (noise until then)
// I asked chatGTP if it was a photo, but it could tell it was digital art.
//@ common
#define Main void mainImage(out vec4 Q, in vec2 U)
#define R iResolution.xy
#define A(U) texture(iChannel0,(U)/R)
#define B(U) texture(iChannel1,(U)/R)
#define C(U) texture(iChannel2,(U)/R)
//@ buffer A
//@ iChannel0 = image
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
Main {
    float t = iTime;
    Q = vec4(0);
    Q += .05*A(U*2.+t);
    Q += .1*A(U+t);
    Q += .2*A(U*.5+t);
    Q += .3*A(U*.25+t);
    Q += .4*A(U*.125+t);
    Q += .5*A(U*.125+t);
    Q += .75*A(U*.125*.5);
    Q += 1.*A(U*.125*.25);
    Q += 2.*A(U*.125*.125);

}
//@ buffer B
//@ iChannel0 = A
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
Main {
    
    vec4 n = A(U+vec2(0,1));
    vec4 e = A(U+vec2(1,0));
    vec4 s = A(U-vec2(0,1));
    vec4 w = A(U-vec2(1,0));
    
    Q.y = n.x-s.x;
    Q.x = e.x-w.x;
    Q.xy = .1*Q.xy+vec2(-Q.y,Q.x);
    
}
//@ buffer C
//@ iChannel0 = A
//@ iChannel1 = B
//@ iChannel2 = none
//@ iChannel3 = none

Main {

    for (float i = 0.; i < 100.; i++) {
        U += 5.*B(U).xy;
    }
    Q = A(U).xxxx;
}
//@ buffer D
//@ iChannel0 = C
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
Main {
    
    vec4 n = A(U+vec2(0,1));
    vec4 e = A(U+vec2(1,0));
    vec4 s = A(U-vec2(0,1));
    vec4 w = A(U-vec2(1,0));
    
    Q.y = n.x-s.x;
    Q.x = e.x-w.x;
    
}
//@ image
//@ iChannel0 = D
//@ iChannel1 = C
//@ iChannel2 = image
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
Main {
    
    float h = 1.-.8*exp(-.01*abs(U.y-.4*R.y));
    
       
    
    if (U.y < .4*R.y) {
        U.y = abs(-U.y+.8*R.y);
        U.x += 30.*sin(100.*U.y/R.y)+5.*sin(39.*U.x/R.y);
        U.y += 30.*sin(100.*U.y/R.y)+5.*sin(39.*U.x/R.y);
    }
    
    Q = B(U);
    vec2 v = normalize(U-.7*R)*(1.-exp(-10.*length(U-.7*R)/R.y));
    for (float i = 0.; i < 180.; i++){
        Q -= (vec4(.7,.6,.5,1))*B(U-v*i*R.y/100.)*.03;
        Q += (1.-vec4(.7,.6,.5,1))*B(U-v*i*R.y/100.)*.01;
        Q += .2*vec4(.7,.6,.5,1)*exp(-4.*length(U-v*i*R.y/100.-.7*R)/R.y);
    }
    Q *= .1*(B(U));
    float m = .05*R.y*(C(vec2(U.x,0)).x*.2+C(vec2(.1*U.x,0)).x)+.1*R.x-U.x*.1;
    Q *= .5+.5*smoothstep(0.,2.,U.y-.4*R.y-m);
    m = .05*R.y*(C(vec2(U.x,10)).x*.2+C(vec2(.1*U.x,10)).x)+.07*R.x-U.x*.1;
    Q *= .75+.25*smoothstep(0.,2.,U.y-.4*R.y-m);
    m = .05*R.y*(C(vec2(U.x,20)).x*.2+C(vec2(.1*U.x,20)).x)+.02*R.x-U.x*.1;
    Q *= .9+.1*smoothstep(0.,2.,U.y-.4*R.y-m);
    
    Q *= h;
    
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
