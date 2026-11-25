varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// Flat drop-shadow silhouette, shared by Fabric and Stuff.
// The caller draws the sprite 1px lower with this shader, then draws the real sprite on top,
// so only the 1px band directly below the sprite's bottom edges stays visible.
// (The old version sampled the texel above inside the sprite's own quad, so the band
// below the sprite's last row fell outside the quad and was clipped.)
void main()
{
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
    if (c.a <= 0.0)
    {
        discard;
    }
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.55 * v_vColour.a);
}
