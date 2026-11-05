// Shader fragment  [VS slot 150]  toClipSpaceInstanced

// ---- uniform parameters ----
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000
uniform struct { float4 origin; float4 invWidth; float4 tuning; } volumeInfo;   // reg-meta 02c002c00003000000000008

// ---- fragment body (spliced into the generated main()) ----
float3x4 m2w = float3x4(In.texcoord0, In.texcoord1, In.texcoord2);
float3 boxDimension = float3(volumeInfo.origin.w, volumeInfo.invWidth.w, volumeInfo.tuning.w);
float4 corner = float4(In.position.xyz*boxDimension + volumeInfo.origin.xyz, 1);
float4 worldPosition = float4(mul(m2w, corner), 1);
float4 clipPosition = mul(worldPosition, worldToClip);
Current.position = clipPosition;
