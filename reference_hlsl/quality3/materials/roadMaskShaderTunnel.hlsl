// Material shader: roadMaskShaderTunnel
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: copyUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
    // --- fragment: roadMaskVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xyz = In.texcoord1.xyz;
    Current.texcoord<t1>.xyz = worldPosition.xyz;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_pixel()
{
    // --- fragment: roadMaskDebugPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv0 = In.texcoord<t0>.xy;
    float3 uv1 = In.texcoord<t1>.xyz;
    float maskColor = (uv0.x >= 0 && uv0.x <= 1 && uv0.y >= 0 && uv0.y <= 1) ? 1 : 0;
    float zAcceleration = uv1.x;
    float accelColor = 1 - saturate(zAcceleration * 20);
    Current.color.rgb = float3(maskColor, accelColor, 1);
    Current.color.rgb *= float3(0.7, 0.7, 0.7); 
    Current.color.a = 0.3;
}
