// Shader fragment  [VS slot 258]  unitParticleTransformVS

// ---- uniform parameters ----
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000
uniform struct { float4 texXform; float4 worldSpaceCardData; float4 cameraSpaceCardData; float4x3 cameraTransform;} unitImpostorParticles[16];   // reg-meta 02cc02cc0060000000000008

// ---- declarations / helper functions ----
static const float kZBiasFactor = -0.00001f;
static const float2 vtxInfo[ 4 ] =
{
float2( 0.0f, 0.0f ),
float2( 1.0f, 0.0f ),
float2( 1.0f, 1.0f ),
float2( 0.0f, 1.0f )
};

// ---- fragment body (spliced into the generated main()) ----
float2 modelData = In.texcoord0.xy;
float3 position  = modelPosition.xyz;
position = mul( float4( position, 1.0f ), modelToWorld );
// Get information for this corner of the quad.
float2 quadCorner = vtxInfo[ modelData.x ];
// Get model index.
int cellIndex = modelData.y;
float4 texXform            = unitImpostorParticles[ cellIndex ].texXform;
float4 worldSpaceCardData  = unitImpostorParticles[ cellIndex ].worldSpaceCardData;
float4 cameraSpaceCardData = unitImpostorParticles[ cellIndex ].cameraSpaceCardData;
float3 cardDepth           = unitImpostorParticles[ cellIndex ].cameraTransform[ 3 ];
// Offset in world space.
float3 worldOffset = float3( worldSpaceCardData.xy + worldSpaceCardData.zw * quadCorner, 0.0f );
// Rotate offset by camera view (which is the camera matrix in world space).
worldOffset.xyz = mul( float4( worldOffset.xzy, 0.0f ), unitImpostorParticles[ cellIndex ].cameraTransform );
// Get camera space position & offset to quad corner.
float3 viewPos = mul( float4( position + worldOffset, 1.0f ), worldToCamera );
// Get clip space position of quad corner.
float4 clipPos = mul( float4( viewPos, 1.0f ), cameraToClip );
// Z-bias.
clipPos.z += clipPos.w * kZBiasFactor;
// Get UV.
float2 uv = texXform.xy + texXform.zw * quadCorner;
Current.position       = clipPos;
Current.texcoord<t0>   = float4( uv, quadCorner );
 Current.texcoord<t0>.y = 1.0f - Current.texcoord<t0>.y; 
Current.texcoord<t1>   = modelPosition;
// Offset in camera space.
float3 camOffset            = float3( cameraSpaceCardData.xy + cameraSpaceCardData.zw * quadCorner, cardDepth.x );
float3 cameraAlignedViewPos = mul( float4( position, 1.0f ), worldToCamera ) + camOffset;
// Get clip space position of quad corner.
float4 cameraAlignedClipPos = mul( float4( cameraAlignedViewPos, 1.0f ), cameraToClip );
