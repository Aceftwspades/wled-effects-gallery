// cool pattern culegamer by CuleGamer - https://www.shadertoy.com/view/lXVSWt - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: cool pattern culegamer (CuleGamer)
// cool pattern culegamer by CuleGamer
// https://www.shadertoy.com/view/lXVSWt
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// This is probably the worst code I have ever written; for some reason I just don't feel like making it better.
// I would love to see your golfs(is that the plural of golf?) of this.
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end
void mainImage(out vec4 O, in vec2 I)
{
    vec2 uv = 10. * (2. * I - iResolution.xy) / iResolution.y;
    float val = cos(length(uv) - 4. * iTime + cos(2. * iTime) * cos(iTime + 3. * atan(uv.y, uv.x)));
    val = abs(val - 0.5);
    vec3 col = val * clamp(abs(mod((0.25 * iTime + 0.318309886184 * atan(uv.y,uv.x))*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
    O = vec4(col,1.0);
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
