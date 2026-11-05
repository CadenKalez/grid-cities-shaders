// Shader fragment  [PS slot 428]  pointGelBlendPF

// ---- uniform parameters ----
uniform float4x4 clipToModel;   // reg-meta 022702270004000000004001
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;   // reg-meta 02aa02aa0004000000000008
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000
uniform float4x3 worldToModel;   // reg-meta 002a002a0003000000000001

// ---- declarations / helper functions ----
extern uniform sampler gelSampler0 : register( s0 );
extern uniform sampler gelSampler1 : register( s1 );

// ---- fragment body (spliced into the generated main()) ----
float3 mpos = mul( float4( pos.xyz, 1 ), worldToModel );
float4 gelValues0 = texCUBE( gelSampler0, mpos.xzy );
float4 gelValues1 = texCUBE( gelSampler1, mpos.xzy );
float4 gelValues = lerp( gelValues0, gelValues1, blend );
Current.color.rgb *= gelValues.rgb;
