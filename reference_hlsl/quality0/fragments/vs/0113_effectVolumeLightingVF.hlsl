// Shader fragment  [VS slot 113]  effectVolumeLightingVF

// ---- uniform parameters ----
uniform float4 patchLocation;   // reg-meta 022602260001000000000008
uniform struct { float4 mDir; float4 mColor; } dirLightsWorld[4];   // reg-meta 021402140008000000003fc0

// ---- fragment body (spliced into the generated main()) ----
{
const float ambient = 0.25;
float3 lightingNormal = normalize( quadPos - patchLocation );
float LdotN = saturate( dot( lightingNormal, dirLightsWorld[0].mDir.xyz ) );
color.rgb = lerp( color.rgb * dirLightsWorld[0].mColor * LdotN, color, ambient );
}
