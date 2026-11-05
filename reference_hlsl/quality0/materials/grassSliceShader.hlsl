// Material shader: grassSliceShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000080044000000000000000100000001ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: unpackNormal   (cond 01022c0000000000000004000000000000000100000001ff)
    Current.normal.xyz = Current.normal.xyz * 1.0/127.0 - 1;
    // --- fragment: grassSliceVS   (cond 0000000000000000000000000000000000000000000000ff)
    {
    float scale = 1.0;  
    float3 localPosition = modelPosition.xyz;
    float3 worldPosition = localPosition;
    float3 worldNormal = In.normal.xyz;
    Current.position = float4(worldPosition,1);
    float alpha = modelPosition.w;  
    Current.texcoord0 = float4(worldNormal, alpha);      
    Current.texcoord1 = float4(worldPosition, 0);
    Current.texcoord2 = float4(In.texcoord0.xyz, 0);  
    }
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_pixel()
{
    // --- fragment: grassSlicePS   (cond 0000000000000000000000000000000000000000000000ff)
    static const float distAcrossClump = 16.0;  
    float delme1 = abs(In.texcoord<t1>.x) - (distAcrossClump*0.5);
    delme1 = (delme1 > 0) ? -1 : 0;
    float delme2 = abs(In.texcoord<t1>.y) - (distAcrossClump*0.5);
    delme2 = (delme2 > 0) ? -1 : 0;
    float delme3 = abs(In.texcoord<t1>.z) - (distAcrossClump*0.5);
    delme3 = (delme3 > 0) ? -1 : 0;
    clip(delme1);
    clip(delme2);
    clip(delme3);
    clip(In.texcoord<t1>.z);  
    float bladeID = In.texcoord<t0>.w;
    Current.color = float4(In.texcoord<t0>.xyz * 0.5 + 0.5, bladeID);  
    Current.color1 = float4(In.texcoord<t2>.rgb, 1.0);
}
