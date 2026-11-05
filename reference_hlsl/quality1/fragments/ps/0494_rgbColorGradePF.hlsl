// Shader fragment  [PS slot 494]  rgbColorGradePF

// ---- uniform parameters ----
uniform float4x4 colorMatrix;   // reg-meta 02a602a60004000000000008

// ---- declarations / helper functions ----
extern uniform sampler      screenSampler   : register( s0 );

// ---- fragment body (spliced into the generated main()) ----
float2 uv                   = In.texcoord0.xy;
float4 color                = tex2D( screenSampler, uv );
Current.color.rgb           = float3( dot( colorMatrix[0], color.rgb ), dot( colorMatrix[1], color.rgb ), dot( colorMatrix[2], color.rgb ) );
Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
