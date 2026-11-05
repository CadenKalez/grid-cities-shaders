// Shader fragment  [PS slot 103]  effectSimpleSkyParticleDepthNormalPS

// ---- uniform parameters ----
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
{
clip( diffuse.a - 0.5 );
float currentDepth = (particleClipPos.w + 100)* nearFar.w * 255.0; 
Current.color.xyz = float3(floor(currentDepth) / 255.0, floor(frac(currentDepth)*255.0) / 255.0, frac(currentDepth*255.0));  
Current.color.w = diffuse.a;
}
