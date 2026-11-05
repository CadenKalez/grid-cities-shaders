// Shader fragment  [PS slot 37]  depthNormalInfo

// ---- uniform parameters ----
uniform float4 renderTargetInfo0;   // reg-meta 025a025a0001000000004000

// ---- declarations / helper functions ----
extern uniform sampler normalMap : register(s14);
extern uniform sampler depthMap  : register(s15);
float UnpackDepth(float4 rgbaDepth)
{
return dot( rgbaDepth.xyz, float3( 1, 1 / 255.0, 1 / (255.0*255.0) ) );
}

// ---- fragment body (spliced into the generated main()) ----
float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
float4 rgbaDepth = tex2D(depthMap, screenUV);
float depth = UnpackDepth(rgbaDepth);
float3 worldNormalPack = tex2D(normalMap, screenUV).xyz;
float3 worldNormal = normalize(2 * worldNormalPack - 1);
