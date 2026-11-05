// Shader fragment  [PS slot 440]  lineQuadPF

// ---- uniform parameters ----
uniform float4x4 clipToCamera;   // reg-meta 022902290004000000004000
uniform float4 deferredInfo;   // reg-meta 02ad02ad0001000000000008
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

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
float3 crwpFarClip      = In.texcoord<t0>.xyz;
float  vposZ            = In.texcoord<t0>.w;
float4 diffLightColor   = In.texcoord<t1>;
float3 p0               = In.texcoord<t2>.xyz;
float  radius2          = In.texcoord<t2>.w;
float3 p1               = In.texcoord<t3>.xyz;
float  innerRadius2     = In.texcoord<t3>.w;
float2 param            = In.texcoord<t4>.xy;
float2 screenUV         = In.texcoord<t4>.zw;
float3 rayNormal        = In.texcoord<t5>.xyz;
float  rayLen2          = In.texcoord<t5>.w;
float4 normalValues = tex2D( normalSampler, screenUV );
float4 depthValues = tex2D( depthSampler, screenUV );
float3 normal = normalValues.xyz * 2 - 1;
float gloss = normalValues.w;
float depth = unpackDepth( depthValues.xyz );
float specPow = depthValues.w * 255.0;
float3 dir = crwpFarClip * depth / vposZ;
float3 pos = dir + worldCameraPosition.xyz;
float3 toPos = pos.xyz - p0;
float  c2 = dot( toPos, toPos );
float  a = dot( toPos, rayNormal );
float  a2 = a*a;
float  b2 = c2 - a2;
float  d2 = b2;
float3 p3 = p0 + rayNormal * a;
float3 lightDir = p3 - pos.xyz;
float3 lightDirNormal = normalize( lightDir );
float  distP02 = c2;
float3 toPos1 = pos.xyz - p1;
float  distP12 = dot( toPos1, toPos1 );
float attenDist2 = d2;
attenDist2 = a2 < 0 ? distP02 : attenDist2;
attenDist2 = a2 > rayLen2 ? distP12 : attenDist2;
float atten = saturate( attenDist2 * param.x + param.y );
float ndotl = saturate( dot( normal.xyz, lightDirNormal ) );
Current.color = diffLightColor * ndotl * atten * atten;
