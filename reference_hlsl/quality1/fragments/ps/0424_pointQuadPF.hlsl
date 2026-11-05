// Shader fragment  [PS slot 424]  pointQuadPF

// ---- uniform parameters ----
uniform float4x4 clipToCamera;   // reg-meta 022902290004000000004000

// ---- declarations / helper functions ----
float3 mulq(float3 v, float4 q)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}
float unpackDepth( float3 packeddepth )
{
return dot( packeddepth, float3( 1, 1 / 255.0f, 1 / (255.0*255.0) ) );
}
extern uniform sampler      normalSampler   : register( s14 );
extern uniform sampler      depthSampler    : register( s15 );

// ---- fragment body (spliced into the generated main()) ----
float2 screenUV         = In.texcoord<t0>.xy;
float4 diffLightColor   = In.texcoord<t1>;
float3 toViewFarClip    = In.texcoord<t2>.xyz;
float3 lightPos         = In.texcoord<t3>.xyz;
float  denom            = In.texcoord<t3>.w;
float2 param            = In.texcoord<t4>.xy;
float  innerRadius2     = In.texcoord<t4>.w;
float4 normalValues = tex2D( normalSampler, screenUV );
float4 depthValues = tex2D( depthSampler, screenUV );
float3 normal = normalValues.xyz * 2 - 1;
normal = normalize( normal );
float gloss = normalValues.w;
float depth = unpackDepth( depthValues.xyz );
float specPow = depthValues.w * 255.0;
float3 pos = toViewFarClip * depth;
float3 lightDir = lightPos.xyz - pos.xyz;
float d2 = dot( lightDir, lightDir );
float3 lightDirNormal = normalize( lightDir );
float atten = saturate( d2 * param.x + param.y );
float ndotl = saturate( dot( normal.xyz, lightDirNormal ) );
Current.color   = diffLightColor * ndotl * atten;
