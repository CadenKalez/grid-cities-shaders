// Material shader: TerrainNormalsShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionColorUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 mParams; } terrainNormalsInfo;
uniform float4 samplerInfo0;
float ComputeAOTerm(sampler heightMap, in float2 heightMapUV, in float2 aoTapSpacing)
{
const float power = 0.9;
const float contrast = 0.18;
const int aoSamples = 10;
const float darkness = (4 * 8.0) / aoSamples;
const float step = (3.14159 * 2.0) / aoSamples;
const float startAngle = 40.0 / 57.3;
float spacing = (1.0 / 256.0) * contrast * aoTapSpacing.y;
float currentHeight = tex2D(heightMap, heightMapUV).x;
float2 sc = float2(0,0);
float occluded = 0;
for (int i = 0; i < aoSamples; i++)
{
float a = startAngle + step * i;
sincos(a, sc.x, sc.y);
float2 uv = float2(sc.x * spacing * (1+i%2), sc.y * spacing * (1+i%2));
float sample = tex2D(heightMap, heightMapUV + uv).x;
float o = saturate(sample - currentHeight);
occluded += o;
}
occluded = pow(occluded, power);
occluded *= darkness;
return saturate(occluded);
}
float3 ComputeAOColor(float term)
{
const float3 aoColorMin = float3(1.0, 1.0, 1.0);
const float3 aoColorMax = float3(0.405, 0.34, 0.32) * 0.1;
float3 finalAOColor = lerp(aoColorMin, aoColorMax, term);
return finalAOColor;
}
float3 ComputeAOColorForHeavyLayer(float term)
{
const float3 aoColorMin = float3(1.0, 1.0, 0.95) * 1.1;
const float3 aoColorMax = float3(1.0, 1.0, 1.0) * -1.15;
float3 finalAOColor = lerp(aoColorMin, aoColorMax, term*term);
return finalAOColor;
}
extern uniform sampler HeightMap : register(s0);

void main_pixel()
{
    // --- fragment: terrainNormalsPS   (cond 0000000000000000000000000000000000000000000000ff)
    const float mapSize = terrainNormalsInfo.mParams.x;
    const float spacing = 1.0 / mapSize * terrainNormalsInfo.mParams.y * 1.0 / 13.0;
    const float heightScale = terrainNormalsInfo.mParams.z;
    const float normalScale = terrainNormalsInfo.mParams.w * 0.25;
    float2 uv = In.texcoord<t0>.xy;// - 0.25*samplerInfo0.zw;
    float3 p[9];
    p[0].xy = uv + float2(  0,  0 ) * samplerInfo0.zw;
    p[1].xy = uv + float2( -1, -1 ) * samplerInfo0.zw;
    p[2].xy = uv + float2( -1,  0 ) * samplerInfo0.zw;
    p[3].xy = uv + float2( -1,  1 ) * samplerInfo0.zw;
    p[4].xy = uv + float2(  0 , 1 ) * samplerInfo0.zw;
    p[5].xy = uv + float2(  1,  1 ) * samplerInfo0.zw;
    p[6].xy = uv + float2(  1,  0 ) * samplerInfo0.zw;
    p[7].xy = uv + float2(  1, -1 ) * samplerInfo0.zw;
    p[8].xy = uv + float2(  0, -1 ) * samplerInfo0.zw;
    p[0].z = tex2D(HeightMap, p[0].xy).x;
    p[0].z *= heightScale;
     [unroll]
    for( int i = 1; i < 9; i++ )
    {
    p[i].z = tex2D(HeightMap, p[i].xy).x;
    p[i].z *= heightScale;
    p[i] -= p[0];
    }
    float3 normal = float3(0.,0.,0.);
     [unroll]
    for( int k = 1, j = 8; k < 9; j = k++ )
    {
    normal += ( cross( p[k], p[j] ) );
    }
    normal /= 8;
    normal = normalize(normal);
    normal.z = pow( normal.z, 4) ; 
    normal = normalize(normal);
    float3 packednormal = normal * 0.5 + 0.5;
    float2 aoTapSpacing = terrainNormalsInfo.mParams.yw;
    Current.color = float4(packednormal.xyz, sqrt(ComputeAOTerm(HeightMap, uv, aoTapSpacing )) );  
    //Current.color.rgb = tex2D(HeightMap, uv.xy ).x * 10 - 0.45;
    //Current.color.rgb = p1.zzz * 0.5 + 0.5;
}
