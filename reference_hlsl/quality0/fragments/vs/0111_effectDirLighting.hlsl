// Shader fragment  [VS slot 111]  effectDirLighting

// ---- uniform parameters ----
uniform struct { float4 mDir; float4 mColor; } dirLightsWorld[4];   // reg-meta 021402140008000000003fc0

// ---- fragment body (spliced into the generated main()) ----
{
const float ambient = 0.5;
float LdotN = saturate( dot( normal, dirLightsWorld[0].mDir.xyz ) );
color = lerp( color * dirLightsWorld[0].mColor * LdotN, color, ambient );
}
