// Spheronoi III by domrally - https://www.shadertoy.com/view/dt3yWX - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: Spheronoi III (domrally)
// Spheronoi III by domrally
// https://www.shadertoy.com/view/dt3yWX
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// textures:
//   Image's iChannel0 was a texture on Shadertoy - choose a picture of your own for it beside the deck's channels (noise until then)
// Click & Drag!
// [url=https://www.shadertoy.com/playlist/fXjyRd]GEOMETRY PLAYLIST[/url]
//@ image
//@ iChannel0 = image
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
/*
by Dom Mandy in 2024
*/

// rotation
vec3 r(vec3 V, float a) {
    V.xz = vec2(cos(a += atan(V.z, V.x)), sin(a)) * length(V.xz);
    return V;
}

void mainImage(out vec4 M, vec2 C) {
    // animation
    M = iMouse;
    float l, i, p,
          n = 9.,
          a = mix(iTime / 3., M.x / 2e2, sign(M.z));
    vec3 P, X, N,
         R = iResolution,
         F = r(vec3(0, 0, 1), a),
         E = r(vec3(1.1 * (C + C - R.xy) / R.y, -1), a),
         L = r(normalize(vec3(1, 2, 3)), a);

    // surface normals
    for(; i < 256.;)
        if (n > (p = dot(X -= F * dot(P *= sign(p = dot(P /= length(P = texture(iChannel0, vec2(iTime / 2e3, i++ / 256.)).rgb - .5), F)), X = P - E) / abs(p), X)))
            n = p, N = P;

    // lighting
    l = pow(max(max(.9 * dot(L, N), .04), -dot(F, reflect(L, N))), inversesqrt(dot(F, N)));
    M = sqrt(l + (l - l * l * l) * cos(atan(N.z, N.x) - vec4(0, 2, 4, 6)));
}


/*
SEE ALSO

https://en.wikipedia.org/wiki/Voronoi_diagram
https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection
*/


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
