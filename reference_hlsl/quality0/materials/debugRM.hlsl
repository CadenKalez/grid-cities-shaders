// Material shader: debugRM
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];
float3 batchedQuat(float4 q, float3 v)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: copyUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
    // --- fragment: copyVertexColor   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: toWorldSpaceBatched   (cond 0102c10000000000000000000000000000000000000000ff)
    int meshBatchIndex1 = toInt(Current.indices.x);
    Current.position.xyz *= batchInstanceInfo[meshBatchIndex1].translation.w;
    Current.position.xyz = batchedQuat(batchInstanceInfo[meshBatchIndex1].rotation, Current.position.xyz);
    Current.position.xyz += batchInstanceInfo[meshBatchIndex1].translation.xyz;
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler2D diffuseSampler        : register(s0);
sampler2D normalSampler         : register(s1);
sampler2D shaderSampler         : register(s2);

void main_pixel()
{
    // --- fragment: debugReliefMap   (cond 0000000000000000000000000000000000000000000000ff)
    float4 diffuseTex = tex2D(diffuseSampler, In.texcoord<t0>.xy);
    Current.color.rgba = float4(diffuseTex.xyz + diffuseTex.www, 1);
    float4 normalTex = tex2D(normalSampler, In.texcoord<t0>.xy);
    float3 normal = normalTex.xyz * 2 - 1;
    float3 lightDir = normalize(float3(0.4,0.4,1));
    float light = saturate(dot(normal, lightDir)) * 0.8 + 0.2;
    Current.color.rgb *= saturate(light);
}
