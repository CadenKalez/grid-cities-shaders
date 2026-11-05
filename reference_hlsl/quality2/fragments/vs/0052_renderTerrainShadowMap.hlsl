// Shader fragment  [VS slot 52]  renderTerrainShadowMap

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4x3 modelToCamera;   // reg-meta 000700070003000000004001
uniform float4 rangeAndStrength;   // reg-meta 022302230001000000000008

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0>.x = (mul(Current.position, modelToCamera).z - rangeAndStrength.x) * rangeAndStrength.y;
Current.position = mul(Current.position, modelToClip);
float bias=0.001; 
float sectionIndex=rangeAndStrength.w;
if ( sectionIndex >= 2 )
{
bias=0.0110; 
}
else if ( sectionIndex >= 1 )
{
bias=0.05; 
}
else
{
bias=0.10165; 
}
Current.position.z+=bias;
Current.position.z= Current.position.z<0.001 ? 0.001: Current.position.z;
