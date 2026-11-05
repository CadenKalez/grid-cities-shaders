// Material shader: selectionRoadShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 worldToClip;

void main_vertex()
{
    // --- fragment: outlineVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = Current.position;
    Current.position = mul(float4(Current.position.xyz, 1), worldToClip);
}

//==============================================================================
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler2D currentHeightMap : register(s15);

void main_pixel()
{
    // --- fragment: clipOutlineBasedOnHeightPS   (cond 0000000000000000000000000000000000000000000000ff)
    // Mask out geometry beneath the terrain. Needed for roads because of their retaining
    // walls.
    float4 worldPos = In.texcoord<t0>;
    worldPos.z += 0.5f; // z-bias for terrain clipping through road
    float2 topDownUV = (worldPos.xy / 2048.0f) + 0.5f;
    //float4 controlMap = tex2D(currentHeightMap, topDownUV);
    //float height = controlMap.x + controlMap.y / 255.0; // [0,1]
    float height = tex2D(currentHeightMap, topDownUV).r;
    height *= 2048.0f;
    height -= 1024.0f;
    clip(worldPos.z - height);
    // --- fragment: solidSelectionPS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.rgba = float4(0,1,0,1);
}
