// Shader fragment  [PS slot 106]  networkRoadBasicBaseColor

// ---- uniform parameters ----
uniform float4 materialColor;   // reg-meta 002200220001000000000010

// ---- fragment body (spliced into the generated main()) ----
float4 v4Diffuse = tex2D( diffuseSampler, baseUV );
float4 v4NoiseMask = tex2D( noiseMaskSampler, float2(tileUV.x, tileUV.y/96.0) );
clip(v4Diffuse.a - 0.75); 
float noiseAlpha = v4NoiseMask.a * saturate(saturate(tileUV.z / 48.0f) * (abs(frac(worldPosition.x/73.0)-0.5) * abs(frac(worldPosition.y/87.0)-0.5) * 4 + 0.65));
Current.color.rgb = lerp(v4Diffuse.rgb,v4NoiseMask.rgb,noiseAlpha) * materialColor.rgb;
Current.color.w = materialColor.a;
