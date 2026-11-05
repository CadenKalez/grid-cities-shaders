// Shader fragment  [PS slot 427]  pointGelPF

// ---- uniform parameters ----
uniform float4x4 clipToModel;   // reg-meta 022702270004000000004001
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;   // reg-meta 02aa02aa0004000000000008
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000
uniform float4x3 worldToModel;   // reg-meta 002a002a0003000000000001

// ---- declarations / helper functions ----
extern uniform sampler gelSampler : register( s0 );

// ---- fragment body (spliced into the generated main()) ----
float3 mpos = mul( float4( pos.xyz, 1 ), worldToModel );
float4 gelValues = texCUBE( gelSampler, mpos.xzy );
Current.color.rgb *= gelValues.rgb;
