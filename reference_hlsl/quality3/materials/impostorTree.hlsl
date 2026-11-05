// Material shader: impostorTree
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 projScale; float4 projOffset; float4 scale[8]; float4 offset[8]; float4x4 transform[8];} scImpostorAtlasPosition;
uniform float4x3 worldToCamera;

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000000000000000000000000000000000ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: impostorOffscreenInstanceData   (cond 0000000000000000000000000000000000000000000000ff)
    int angle = int(In.texcoord4.x * 255 + 0.5);
    // --- fragment: impostorTreeVS   (cond 0000000000000000000000000000000000000000000000ff)
    float leavesFallen = scImpostorAtlasPosition.projScale.w;
    Current.texcoord<t0> = float4(In.texcoord0.xy + float2(0, 1), In.texcoord1.xy + float2(0, 1));
    Current.position.xyz = mul(float4(Current.position.xyz,0), scImpostorAtlasPosition.transform[angle]).xyz;
    Current.position.xyz = mul(float4(Current.position.xyz,0), worldToCamera).xyz;
    Current.position.xyz *= scImpostorAtlasPosition.projScale.xyz;
    Current.position.xyz += scImpostorAtlasPosition.projOffset.xyz;
    Current.texcoord<t1> = float4(Current.position.xyz, 0);
    Current.position.xyz *= scImpostorAtlasPosition.scale[angle].xyz;
    Current.position.xyz += scImpostorAtlasPosition.offset[angle].xyz;
    float3 vertNormal = Current.normal.xyz;
    vertNormal = mul(float4(vertNormal, 0), scImpostorAtlasPosition.transform[angle]).xyz;
    Current.texcoord<t2> = float4(vertNormal, leavesFallen);
    float3 vertTangent = Current.tangent.xyz;
    vertTangent = mul(float4(vertTangent, 0), scImpostorAtlasPosition.transform[angle]).xyz;
    Current.texcoord<t3> = float4(vertTangent, 0);
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
static const bool kPerPixelDepth = true;
float4 ImpostorUnpackNormalDepth(float4 normalMapSample)
{
float2 normalXY = normalMapSample.xy * 2 - 1;
float  xyLen = dot(normalXY, normalXY);
float  depthZSign = normalMapSample.z - 0.5;
float  pixDepth = abs(depthZSign * 2);
float  zSign = (depthZSign >= 0) ? 1 : -1;
float  normalZ = zSign * sqrt(1 - xyLen);
return float4(normalXY, normalZ, pixDepth);
}
float3 ImpostorPackNormalDepth(float3 normal, float pixelDepth)
{
normal = normalize(normal);
float zSign = (normal.z >= 0) ? 0.5 : -0.5;
return float3(normal.xy * 0.5 + 0.5, zSign*pixelDepth + 0.5);
}
float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmapNormal)
{
float3 vn = normalize(vertNormal);
float3 dt = normalize(cross(vn, vertDS));
float3 ds = cross(dt, vn);
nmapNormal = normalize(nmapNormal.r * ds + nmapNormal.g * dt + nmapNormal.b * vn);
return nmapNormal;
}

void main_pixel()
{
    // --- fragment: treeImpostorDepthFragments   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: impostorTreeCommonPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 clipPosition = In.texcoord<t1>.xyz;              
    clip(float4(1 + clipPosition.xy, 1 - clipPosition.xy));
    float2 uv0 = In.texcoord<t0>.xy;
    float2 uv1 = In.texcoord<t0>.zw;
    float3 vertNormal = In.texcoord<t2>.xyz;
    float3 vertTangent = In.texcoord<t3>.xyz;
    float leavesFallen = In.texcoord<t2>.w;
    float4 diffuseMap = tex2D(Sampler<s0>, uv0);
    float4 normalMap  = tex2D(Sampler<s1>, uv0);
    float4 aoMap      = tex2D(Sampler<s2>, uv1);
    Current.color.rgb = diffuseMap.rgb * aoMap.rgb;
    float3 nmapNormal = normalMap.xyz * 2.0 - 1.0;
    float3 bumpNormal = ApplyNormalMap(vertNormal, vertTangent, nmapNormal).xyz;
    // --- fragment: impostorTreePS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.a = diffuseMap.a * saturate(100 * (aoMap.a - leavesFallen) + 1);
    Current.color.rgb *= Current.color.a;  
    float3 normalOutput = ImpostorPackNormalDepth(bumpNormal, clipPosition.z);
    Current.color1.rgba = float4(normalOutput, 1.0);
}
