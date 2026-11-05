// Material shader: decalShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (7 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
sampler HeightMap : register(s0);
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;
uniform float4 nearFar;

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000080044000000000000000100000001ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: unpackNormal   (cond 01022c0000000000000004000000000000000100000001ff)
    Current.normal.xyz = Current.normal.xyz * 1.0/127.0 - 1;
    // --- fragment: decalVS   (cond 0000000000000000000000000000000000000000000000ff)
    {
    Current.texcoord1 = In.texcoord0;  
    Current.texcoord0 = Current.position.xyxy / 1024;  
    Current.texcoord0 = 0.5 * (Current.texcoord<t0> + 1);
    Current.texcoord2 = float4(Current.position.xyz, 1);
    float2 uv1 = Current.position.xy;
    uv1 /= 2048.0;
    uv1 += 0.5;
    uv1 = saturate(uv1);
    float height = tex2Dlod(HeightMap, float4(uv1.x, uv1.y, 0, 0)).x * 2048 - 1024;
    height += 0.25;
    Current.position.z = height;
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.texcoord3.xyzw = clipPosition;
    }
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: outputDepthVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color = make_float4(clipPosition.w * nearFar.w * 255.0f);
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000080044000000000000000100000001ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: unpackNormal   (cond 01022c0000000000000004000000000000000100000001ff)
    Current.normal.xyz = Current.normal.xyz * 1.0/127.0 - 1;
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
sampler normalMap : register(s0);  
sampler detailNormalMap   : register(s1);
sampler terrain_edge_gradientMap   : register(s2);
float3 getBestFitNormal( float3 inNormal )
{
return inNormal.xyz * 0.5 + 0.5;
}

void main_pixel()
{
    // --- fragment: decalNormalPS   (cond 0000000000000000000000000000000000000000000000ff)
    const float DETAIL_MAP_TILING = 10;
    const float TERRAIN_NORMAL_SCALE = 0.333;
    const float DETAIL_NORMAL_SCALE = 1.6;  
    float3 terrainNormal = tex2D(normalMap, In.texcoord<t0>.xy).xyz * 2.0 - 1.0;
    float3 detailNormal = tex2D(detailNormalMap, In.texcoord<t0>.xy * DETAIL_MAP_TILING).xyz * 2.0 - 1.0;
    terrainNormal.z *= TERRAIN_NORMAL_SCALE;
    terrainNormal = normalize(terrainNormal);
    detailNormal.z *= DETAIL_NORMAL_SCALE;
    detailNormal = normalize(detailNormal);
    float3 tangent = float3(1,0,0);
    float3 binormal = normalize(cross(terrainNormal, tangent));
    tangent =         normalize(cross(binormal, terrainNormal));
    float3x3 tangentSpace = float3x3(binormal, tangent, terrainNormal);
    float3 worldNormal = mul(detailNormal, tangentSpace);
    worldNormal = normalize(lerp(worldNormal, terrainNormal, 0.25));
    float3 bumpNormal = worldNormal;
    float specE = 64.0 / 255.0;  
    Current.color.a = 1;
    // --- fragment: outputDeferredBumpNormalPS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.w = specE/255.0;
    Current.color1 = float4( getBestFitNormal(bumpNormal.xyz), 1 );
    // --- fragment: outputDepthPS   (cond 0000000000000000000000000000000000000000000000ff)
    float outputDepth = In.color.x;
    Current.color.xyz = float3(floor(outputDepth) / 255.0, floor(frac(outputDepth)*255.0) / 255.0, frac(outputDepth*255.0));
}
