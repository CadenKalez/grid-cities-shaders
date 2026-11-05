// Shader fragment  [PS slot 493]  rgbCubePF

// ---- declarations / helper functions ----
extern uniform sampler      screenSampler   : register( s0 );
extern uniform sampler      cubeSampler     : register( s1 );

// ---- fragment body (spliced into the generated main()) ----
float2 uv                   = In.texcoord0.xy;
float4 color                = tex2D( screenSampler, uv );
float4 clut                 = tex3D( cubeSampler, color.rgb );
Current.color.rgb           = clut.rgb;
Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
