// Shader fragment  [PS slot 491]  rgbCubeStripPF

// ---- declarations / helper functions ----
extern uniform sampler      screenSampler   : register( s0 );
extern uniform sampler      stripSampler    : register( s1 );

// ---- fragment body (spliced into the generated main()) ----
float2 uv                   = In.texcoord0.xy;
float4 color                = tex2D( screenSampler, uv );
color *= 30;
color += 0.5;
color /= 32;
color  = saturate( color );
float2 index0               = float2( color.r, 1-saturate( ( floor( color.b * 32 ) + color.g ) / 32 ) );
float2 index1               = float2( color.r, 1-saturate( ( ceil( color.b * 32 ) + color.g ) / 32 ) );
float3 clut0                = tex2D( stripSampler, index0 ).rgb;
float3 clut1                = tex2D( stripSampler, index1 ).rgb;
Current.color.rgb           = lerp(clut0.rgb,clut1.rgb,frac(color.b*32));
// supposedly doing this will result in better FXAA, but i didn't see much difference.
//Current.color.rgb  = sqrt(Current.color.rgb);
//Current.color.a               = dot(Current.color.rgb, float3(0.299, 0.587, 0.114)); // compute luma;
Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
