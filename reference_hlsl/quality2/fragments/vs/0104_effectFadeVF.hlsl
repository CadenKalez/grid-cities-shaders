// Shader fragment  [VS slot 104]  effectFadeVF

// ---- uniform parameters ----
uniform float4 gameInfo;   // reg-meta 024802480001000000000008
uniform float4 customParams[2];   // reg-meta 020602060002000000000008

// ---- fragment body (spliced into the generated main()) ----
float fadeLevel;
{
float fadeRate = customParams[0].w;
fadeLevel = saturate( age * fadeRate );
}
